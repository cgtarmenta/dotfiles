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

# Check for yay
check_yay() {
    if command -v yay &> /dev/null; then
        log_success "yay is installed"
        return 0
    else
        log_error "yay is not installed. Please install yay first."
        log_info "Visit: https://github.com/Jguer/yay"
        return 1
    fi
}

# Function 1: Full Installation
full_installation() {
    log_info "Starting full installation..."
    
    check_yay || return 1
    
    install_packages || return 1
    deploy_configs || return 1
    configure_wifi || return 1
    setup_waybar_modules || return 1
    install_starship || return 1
    install_optional || return 1
    
    log_success "Full installation completed!"
}

# Function 2: Install Core Packages
install_packages() {
    log_info "Installing core packages..."
    
    check_yay || return 1
    
    log_info "Updating system..."
    yay -Suy --noconfirm
    
    log_info "Installing Hyprland and dependencies..."
    yay -S --noconfirm \
        hyprland warp-terminal waybar \
        swaybg swaylock-effects swaylock-fancy rofi-wayland wlogout swaync thunar \
        swayidle ttf-jetbrains-mono-nerd polkit-gnome starship \
        swappy grim slurp pamixer brightnessctl gvfs \
        bluez bluez-utils blueman nwg-look xfce4-settings \
        dracula-gtk-theme dracula-icons-git xdg-desktop-portal-hyprland \
        wl-gammarelay hyfetch power-profiles-daemon sddm \
        asusctl supergfxctl \
        ttf-fira-code ttf-font-awesome wol jq playerctl flameshot wl-clipboard \
        telegram-desktop discord steam spotify-launcher chromium tailscale fzf btop
    
    if [ $? -eq 0 ]; then
        log_success "Core packages ins        # Enable bluetooth service
        log_info "Enabling Bluetooth service..."
        sudo systemctl enable --now bluetooth.service

        # Enable ASUS / ROG services
        log_info "Enabling ASUS ROG services (asusd, supergfxd)..."
        sudo systemctl enable --now asusd.service supergfxd.service 2>/dev/null || \
            log_warning "asusd/supergfxd services not available or failed to enable"
        
        # Clean out other portals
        log_info "Removing conflicting xdg portals..."
        yay -R --noconfirm xdg-desktop-portal-gnome xdg-desktop-portal-gtk 2>/dev/null
        
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
    local backup_dir="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    
    # Check if configs already exist and backup
    if [ -d "$config_dir/hypr" ] || [ -d "$config_dir/waybar" ]; then
        log_warning "Existing configuration detected"
        read -p "Create backup? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Creating backup at $backup_dir..."
            mkdir -p "$backup_dir"
            [ -d "$config_dir/hypr" ] && cp -R "$config_dir/hypr" "$backup_dir/"
            [ -d "$config_dir/waybar" ] && cp -R "$config_dir/waybar" "$backup_dir/"
            [ -d "$config_dir/kitty" ] && cp -R "$config_dir/kitty" "$backup_dir/"
            log_success "Backup created"
        fi
    fi
    
    log_info "Copying configuration files..."
    cp -R hypr kitty neofetch swayidle swaylock waybar wlogout rofi hyfetch.json "$config_dir/"
    
    # Set executable permissions
    log_info "Setting permissions..."
    chmod +x "$config_dir/hypr/xdg-portal-hyprland"
    chmod +x "$config_dir/waybar/scripts/"*
    
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
        yay -S --noconfirm wol
        
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
        yay -S --noconfirm tailscale
        
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
        yay -S --noconfirm intellij-idea-community-edition || failed_packages+=("intellij-idea-community-edition")
        
        # Slack (prefer Wayland version if available)
        if pacman -Qq slack-desktop-wayland &>/dev/null; then
            log_info "Slack Wayland already installed, skipping..."
        else
            log_info "Installing Slack for Wayland..."
            yay -S --noconfirm slack-desktop-wayland || failed_packages+=("slack-desktop-wayland")
        fi
        
        # Teams
        log_info "Installing Teams for Linux..."
        yay -S --noconfirm teams-for-linux || failed_packages+=("teams-for-linux")
        
        # WhatsApp
        log_info "Installing WhatsApp for Linux..."
        yay -S --noconfirm whatsapp-for-linux || failed_packages+=("whatsapp-for-linux")
        
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

# Main execution check
if [ "$0" = "${BASH_SOURCE[0]}" ]; then
    # Script is being executed directly, not sourced
    log_info "Hyprland Dotfiles Installer"
    log_info "Run with: source install-functions.sh"
    log_info "Then call functions individually, e.g.: install_packages"
fi
