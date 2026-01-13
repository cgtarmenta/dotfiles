# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for a Hyprland-based desktop environment on CachyOS/Arch Linux. It includes configurations for:
- **Hyprland**: Wayland compositor
- **Waybar**: Status bar with custom modules
- **Kitty**: Terminal emulator
- **Rofi**: Application launcher
- **Swaylock**: Screen locker
- **Wlogout**: Logout menu
- Various supporting utilities (swaybg, swayidle, swaync, etc.)

The repository is designed for fresh installations and uses a Rust TUI installer (`installer/`) plus shared shell functions (`install-functions.sh`). The legacy `install.sh` is removed.

## Branch Structure

- `main`: Italian tooltips version
- `main-en`: English tooltips version

## Installation and Setup

### Fresh Installation
```bash
# Clone repository
git clone https://github.com/00Darxk/dotfiles.git
cd dotfiles

# Build/run TUI installer (requires rustup + yay)
cd installer
cargo run --release
```

The TUI handles:
- Package installation via yay
- Config deployment to ~/.config (hypr, waybar, kitty, pipewire, wireplumber, etc.)
- Optional WoL/Tailscale module setup
- Starship shell configuration
- Service enablement (bluetooth, tailscaled)

### Manual Config Deployment
```bash
# Copy configs
cp -R hypr kitty neofetch swaylock waybar wlogout rofi hyfetch.json ~/.config/

# Set executables
chmod +x ~/.config/hypr/xdg-portal-hyprland
chmod +x ~/.config/waybar/scripts/*
```

## Architecture

### Configuration Structure

```
.
├── installer/          # Rust TUI (dotfiles-installer)
├── install-functions.sh# Bash functions invoked by TUI
├── hypr/               # Hyprland compositor config
├── waybar/             # Status bar configs + scripts
├── pipewire/           # PipeWire pulse configs (flat-volumes off)
├── wireplumber/        # WirePlumber rules (flat-volumes off, Logitech soft mixer)
├── kitty/              # Terminal config
├── rofi/               # App launcher
├── swaylock/           # Screen lock config
├── wlogout/            # Logout menu
├── neofetch/           # System info
├── starship.toml       # Shell prompt
└── .bashrc             # Bash initialization
```

### Waybar Custom Modules

Waybar includes several custom modules in `waybar/scripts/`:

1. **WoL Module** (`wol.sh`): Wake-on-LAN magic packet sender
   - Requires: `~/.config/.secrets/ip-address.txt` and `mac-address.txt`
   - Left-click to wake machine
   
2. **Tailscale Module** (`tailscaleinfo.sh`, `connectssh.sh`): 
   - Shows remote machine status via Tailscale
   - Requires: `~/.config/.secrets/hostname.txt`
   - Right-click to SSH into machine
   
3. **Updates Module** (`updates.sh`, `installaupdates.sh`, `listpackages.sh`):
   - Check for system updates
   - Install updates via terminal popup
   
4. **GitHub Notifications** (`github.sh`):
   - Requires: `~/.config/.secrets/notifications.token`
   - See Waybar wiki for token setup
   
5. **System Maintenance** (`sysmaintenance.sh`):
   - Convenience scripts for system upkeep

6. **Media Player** (`mediaplayer.py`):
   - Displays currently playing media via MPRIS
   - Supports Spotify, VLC, mpv, YouTube Music, and more
   - For YouTube Music in browser: install `plasma-browser-integration` and browser extension
   
7. **Weather Module** (`weather.sh`):
   - Fetches weather from wttr.in
   - Configured for Valladolid, Spain by default
   
8. **Storage Module** (`storage.sh`):
   - Shows available disk space
   - Color-coded warnings at 20% and 10% free space

9. **Waybar Launcher** (`launch.sh`):
   - Reloads waybar (bound to Super+O)

### Hyprland Configuration

Key aspects of `hypr/hyprland.conf`:

- **Input**: Italian keyboard layout (`kb_layout = it`)
- **Monitor Setup**: Supports multi-monitor (1920x1080@60Hz defaults)
- **Layout**: Dwindle tiling algorithm
- **Startup Apps**: polkit-gnome, waybar, blueman-applet, nm-applet, swaybg, swaync, wl-gammarelay, tailscale
- **Keybinds**: Super as main modifier (CachyOS-compatible)
  - Super+Return: Terminal (kitty)
  - Super+Q: Kill window
  - Super+E: File manager (thunar)
  - Super+L: Lock (swaylock-fancy)
  - Super+O: Reload waybar
  - Super+Space: App launcher (rofi)
  - Super+F: Fullscreen
  - Super+Y: Pin window
  - Super+K: Toggle group
  - Super+Tab: Next window in group
  - Super+R: Resize mode
  - Super+G/Shift+G: Toggle/restore gaps
  - Print/Ctrl+Print/Alt+Print: Screenshots
  - Super+Shift+S: Flameshot
  - Super+[1-9,0]: Switch to workspace
  - Super+Ctrl+[1-9,0]: Move window to workspace and switch
  - Super+Shift+[1-9,0]: Move window to workspace silently
  - Super+Shift+F[1-9]: Launch specific apps (thunar, whatsdesk, chromium, discord, telegram, steam, codium, spotify)
  - Super+Period/Comma/Slash: Navigate workspaces
  - Super+Minus/Equal: Special workspaces
  - Super+F1: Scratchpad
  - XF86 keys: Volume, brightness, media controls

### Window Rules

Opacity and floating rules for specific applications (kitty, thunar, VSCodium, Chromium, rofi, etc.) are defined as `windowrulev2` directives.

### Secrets Management

Custom waybar modules require secrets stored in `~/.config/.secrets/`:
- `ip-address.txt`: WoL target IP
- `mac-address.txt`: WoL target MAC
- `hostname.txt`: Tailscale SSH target
- `notifications.token`: GitHub API token

**Note**: `.secrets/` is gitignored

## Testing and Validation

No automated tests. Validation is manual:
1. Run Hyprland after installation
2. Verify waybar modules render correctly
3. Test keybindings
4. Check custom module functionality (WoL, Tailscale, updates)

## Development Workflow

### Making Changes to Configs

1. Edit files in the repository clone
2. Test by copying to `~/.config` and reloading:
   ```bash
   # Reload Hyprland config
   hyprctl reload
   
   # Reload waybar
   ~/.config/waybar/scripts/launch.sh
   # or Super+Shift+B keybind
   ```
3. Commit when satisfied

### Adding New Waybar Scripts

1. Create script in `waybar/scripts/`
2. Make executable: `chmod +x waybar/scripts/new-script.sh`
3. Define module in `waybar/modules.jsonc` (or `config.jsonc`)
4. Add module to appropriate group in `waybar/config.jsonc`
5. Test with waybar reload

### Adding New Wallpapers

1. Place image in `hypr/` directory (jpg preferred by author)
2. Add keybind in `hypr/hyprland.conf`:
   ```
   bind = $mainMod SHIFT, Space, [1-4], exec, swaybg -m fill -i ~/.config/hypr/new-wallpaper.jpg
   ```
3. Update `swaylock/config` to change lock screen wallpaper

## Important Notes

- **No Error Checking**: The install script doesn't backup existing configs or validate steps
- **Fresh Install Target**: Designed for clean systems, not incremental updates
- **Dependencies**: Requires yay (AUR helper) pre-installed
- **Attribution**: Config heavily based on SolDoesTech and klpod0s repositories
- **Theming**: Uses Dracula GTK theme and icons, Squared GTK theme available as alternative

## Common Issues

- **Waybar custom modules not showing**: Check if required secret files exist in `~/.config/.secrets/`
- **Keybinds not working**: Verify keyboard layout matches system (config uses Italian layout)
- **Missing fonts/icons**: Ensure nerd fonts are installed (ttf-jetbrains-mono-nerd, ttf-font-awesome)
- **Portal conflicts**: Remove xdg-desktop-portal-gnome and xdg-desktop-portal-gtk if installed

## Version Control

When committing Warp-generated changes, include co-author attribution:
```
Co-Authored-By: Warp <agent@warp.dev>
```
