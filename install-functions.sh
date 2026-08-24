#!/bin/bash

# Hyprland Dotfiles Installation Functions
# This script contains modular installation functions that can be called individually

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper function for logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check for shelly — CachyOS's package manager, and the one this repo targets.
# It covers repositories, the AUR, Flatpaks and AppImages in one tool and
# elevates on its own, so nothing here calls sudo, pacman or yay directly.
check_shelly() {
    if command -v shelly &> /dev/null; then
        log_success "shelly is installed"
        return 0
    else
        log_error "shelly is not installed. Please install shelly first."
        log_info "On CachyOS: sudo pacman -S shelly"
        log_info "Upstream: https://github.com/Seafoam-Labs/Shelly-ALPM"
        return 1
    fi
}

# Shelly deliberately does not auto-route a bare package name between the
# repositories and the AUR when it isn't being driven interactively, so the two
# lists below stay separate and go to `install standard` / `install aur`.
#
# It also has no --needed. `search standard --installed` can't stand in for one:
# it is a fuzzy match that exits 0 whether or not the package is there. So filter
# against the local database explicitly, otherwise every deploy re-run reinstalls
# several hundred megabytes.
#
# Match on Provides as well as Name: a request can already be satisfied by a
# different package. The laptop runs waybar-git, which provides waybar — matching
# names alone would try to install waybar over it and hit the conflict.
not_installed() {
    local satisfied
    satisfied="$(shelly list standard --json 2>/dev/null |
        jq -r '.[] | .Name, (.Provides[]? | split("=")[0])')" || return 1
    local pkg
    for pkg in "$@"; do
        grep -qxF -- "$pkg" <<< "$satisfied" || printf '%s\n' "$pkg"
    done
}

# Install only the missing members of a package list. $1 is the shelly type
# ("standard" or "aur"); the rest are package names. A fully-satisfied list is a
# no-op, not an error.
install_missing() {
    local type="$1"; shift
    local missing
    mapfile -t missing < <(not_installed "$@")

    if [ ${#missing[@]} -eq 0 ]; then
        log_info "All ${type} packages already installed"
        return 0
    fi

    log_info "Installing ${#missing[@]} ${type} package(s): ${missing[*]}"
    shelly install "$type" --no-confirm "${missing[@]}"
}

# Function 1: Full Installation
full_installation() {
    log_info "Starting full installation..."
    
    check_shelly || return 1

    install_packages || return 1
    deploy_configs || return 1
    configure_wifi || return 1
    setup_waybar_modules || return 1
    install_starship || return 1
    install_optional || return 1
    install_grub_theme || return 1
    
    log_success "Full installation completed!"
}

# Function 2: Install Core Packages
install_packages() {
    log_info "Installing core packages..."
    
    check_shelly || return 1

    # --no-flatpak --no-appimage: this step only needs the repos and the AUR up to
    # date, and `upgrade all` fails as a whole if any selected backend fails — on a
    # machine far enough behind that shelly-flatpak-backend isn't installed yet,
    # shelly reports no Flatpak support and takes the repo upgrade down with it.
    # It gets installed below, so later runs could include those backends.
    log_info "Updating system..."
    shelly upgrade all --no-flatpak --no-appimage --no-confirm

    # Every name below is referenced by a bind in hyprland.lua or a widget in
    # waybar/modules.jsonc — keep the two in sync when adding either. Names are
    # split by source because shelly won't guess repo-vs-AUR non-interactively.
    #
    # "rofi", not "rofi-wayland": upstream merged Wayland support into rofi 2.0
    # and the old name now only resolves through rofi's Provides/Replaces
    # compatibility entry, which will not last forever.
    log_info "Installing Hyprland and dependencies..."
    local repo_packages=(
        hyprland warp-terminal waybar
        swaybg swaylock-effects swaylock-fancy rofi wlogout swaync nautilus
        swayidle hypridle uwsm ttf-jetbrains-mono-nerd polkit-gnome starship
        satty grim slurp pamixer brightnessctl gvfs
        bluez bluez-utils blueman nwg-look xfce4-settings
        gnome-themes-extra dracula-icons-git xdg-desktop-portal-hyprland
        hyfetch power-profiles-daemon sddm
        ttf-fira-code ttf-font-awesome wol jq playerctl wl-clipboard
        telegram-desktop discord steam spotify-launcher chromium tailscale
        fzf btop shelly shelly-flatpak-backend
    )
    # clickup-desktop rather than the better-known clickup, whose PKGBUILD
    # carries a sha256 upstream has since invalidated; both give /usr/bin/clickup.
    local aur_packages=(
        dracula-gtk-theme wl-gammarelay
        whatsdesk-bin slack-desktop-wayland clickup-desktop
    )

    install_missing standard "${repo_packages[@]}" &&
    install_missing aur "${aur_packages[@]}"

    if [ $? -eq 0 ]; then
        log_success "Core packages installed successfully"
        
        # Enable bluetooth service
        log_info "Enabling Bluetooth service..."
        sudo systemctl enable --now bluetooth.service
        
        # Clean out other portals
        log_info "Removing conflicting xdg portals..."
        shelly remove standard --no-confirm xdg-desktop-portal-gnome xdg-desktop-portal-gtk 2>/dev/null
        
        log_success "Package installation completed"
        return 0
    else
        log_error "Package installation failed"
        return 1
    fi
}

# Function 3: Deploy Configuration Files
deploy_configs() {
    log_info "Deploying configuration files..."

    local config_dir="$HOME/.config"
    local repo_dir="$(pwd)"
    local backup_dir="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    local items=(hypr kitty neofetch swayidle swaylock waybar wlogout rofi pipewire wireplumber hyfetch.json)

    # Back up anything real (not one of our own symlinks from a previous deploy)
    local needs_backup=0
    for item in "${items[@]}"; do
        [ -e "$config_dir/$item" ] && [ ! -L "$config_dir/$item" ] && needs_backup=1
    done

    if [ "$needs_backup" -eq 1 ]; then
        log_warning "Existing configuration detected"
        read -p "Create backup? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Creating backup at $backup_dir..."
            mkdir -p "$backup_dir"
            for item in "${items[@]}"; do
                if [ -e "$config_dir/$item" ] && [ ! -L "$config_dir/$item" ]; then
                    cp -R "$config_dir/$item" "$backup_dir/"
                fi
            done
            log_success "Backup created"
        fi
    fi

    # Symlink (not copy) so repo edits apply immediately without a redeploy,
    # and the repo is always the single source of truth for what's live.
    log_info "Symlinking configuration files..."
    for item in "${items[@]}"; do
        rm -rf "$config_dir/$item"
        ln -sf "$repo_dir/$item" "$config_dir/$item"
    done

    log_success "Configuration files deployed successfully"
    return 0
}

# Function 4: Configure WiFi Powersave
configure_wifi() {
    log_info "Configuring WiFi powersave..."
    
    local conf_file="/etc/NetworkManager/conf.d/wifi-powersave.conf"
    
    read -p "Disable WiFi powersave mode? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Disabling WiFi powersave..."
        echo -e "[connection]\nwifi.powersave = 2" | sudo tee "$conf_file" > /dev/null
        
        log_info "Restarting NetworkManager..."
        sudo systemctl restart NetworkManager
        
        log_success "WiFi powersave disabled"
        return 0
    else
        log_info "Skipping WiFi powersave configuration"
        return 0
    fi
}

# Function 5: Setup Waybar Modules (WoL and Tailscale)
setup_waybar_modules() {
    log_info "Setting up Waybar modules..."
    
    mkdir -p "$HOME/.config/.secrets"
    
    # WoL Configuration
    read -p "Configure Wake-on-LAN module? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installing wol package..."
        install_missing standard wol
        
        read -p "Enter target IP Address: " ip_address
        read -p "Enter target MAC Address: " mac_address
        
        echo "$ip_address" > "$HOME/.config/.secrets/ip-address.txt"
        echo "$mac_address" > "$HOME/.config/.secrets/mac-address.txt"
        
        log_success "WoL module configured"
    fi
    
    # Tailscale Configuration
    read -p "Configure Tailscale module? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installing Tailscale..."
        install_missing standard tailscale
        
        read -p "Enter hostname: " hostname
        echo "$hostname" > "$HOME/.config/.secrets/hostname.txt"
        
        log_info "Enabling Tailscale service..."
        sudo systemctl enable --now tailscaled
        
        log_info "Connecting to Tailscale network..."
        sudo tailscale up
        
        log_success "Tailscale module configured"
    fi
    
    log_success "Waybar modules setup completed"
    return 0
}

# Function 6: Install Starship Shell
install_starship() {
    log_info "Installing Starship shell..."
    
    read -p "Install and configure Starship? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Configuring .bashrc..."
        
        # Check if starship is already in bashrc
        if ! grep -q "starship init bash" "$HOME/.bashrc"; then
            echo -e '\neval "$(starship init bash)"' >> "$HOME/.bashrc"
        fi
        
        log_info "Copying starship configuration..."
        cp starship.toml "$HOME/.config/"
        
        log_success "Starship shell installed and configured"
        return 0
    else
        log_info "Skipping Starship installation"
        return 0
    fi
}

# Function 7: Install Optional Programs
install_optional() {
    log_info "Installing optional programs..."
    
    read -p "Install optional programs (IntelliJ, Slack, Teams, WhatsApp Desktop)? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installing optional packages..."
        
        # Install packages one by one to handle conflicts better
        local failed_packages=()
        
        # IntelliJ IDEA
        log_info "Installing IntelliJ IDEA Community Edition..."
        install_missing standard intellij-idea-community-edition || failed_packages+=("intellij-idea-community-edition")
        
        # Slack (prefer Wayland version if available)
        if [ -z "$(not_installed slack-desktop-wayland)" ]; then
            log_info "Slack Wayland already installed, skipping..."
        else
            log_info "Installing Slack for Wayland..."
            install_missing aur slack-desktop-wayland || failed_packages+=("slack-desktop-wayland")
        fi
        
        # Teams
        log_info "Installing Teams for Linux..."
        install_missing standard teams-for-linux || failed_packages+=("teams-for-linux")
        
        # WhatsApp
        log_info "Installing WhatsApp for Linux..."
        install_missing aur whatsapp-for-linux || failed_packages+=("whatsapp-for-linux")
        
        if [ ${#failed_packages[@]} -eq 0 ]; then
            log_success "Optional programs installed successfully"
            return 0
        else
            log_warning "Some packages failed to install: ${failed_packages[*]}"
            return 0  # Don't fail the whole step
        fi
    else
        log_info "Skipping optional programs"
        return 0
    fi
}

# Function 8: Install GRUB ROG Theme
install_grub_theme() {
    log_info "Installing ROG GRUB theme..."

    local repo_dir="$(pwd)"
    local theme_src="$repo_dir/grub/themes/ROG"
    local theme_dst="/usr/share/grub/themes/ROG"

    if [ ! -d "$theme_src" ]; then
        log_error "ROG theme not found at $theme_src"
        return 1
    fi

    # Remove any previous copy, then install fresh
    log_info "Copying theme to $theme_dst..."
    sudo rm -rf "$theme_dst"
    sudo mkdir -p "$(dirname "$theme_dst")"
    sudo cp -r "$theme_src" "$theme_dst"

    # Point GRUB at the theme and regenerate the config
    log_info "Configuring GRUB_THEME in /etc/default/grub..."
    if grep -q "^GRUB_THEME=" /etc/default/grub; then
        sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=$theme_dst/theme.txt|" /etc/default/grub
    else
        echo "GRUB_THEME=$theme_dst/theme.txt" | sudo tee -a /etc/default/grub > /dev/null
    fi

    log_info "Regenerating GRUB config..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg

    log_success "ROG GRUB theme installed successfully"
    return 0
}

# Main execution check
if [ "$0" = "${BASH_SOURCE[0]}" ]; then
    # Script is being executed directly, not sourced
    log_info "Hyprland Dotfiles Installer"
    log_info "Run with: source install-functions.sh"
    log_info "Then call functions individually, e.g.: install_packages"
fi
