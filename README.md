# My dotfiles
Configs for Hyprland + Waybar with a TUI installer for fresh CachyOS/Arch setups.


![screen](./showcases/moon-over-mondstat-showcase.png)

> [!NOTE]
> This rice is heavily inspired (copied) from [SolDoesTech](https://github.com/soldoestech)'s hyprland repos, check those if you'd like a probably better tested config. It also uses config taken from [klpod0s](https://github.com/klpod221/klpod0s). If there are any issues with the [hyprland](https://wiki.hyprland.org/) and [waybar](https://github.com/Alexays/Waybar/wiki/) configuration, before opening an issue, check with the wikis as i have no idea what i'm doing, also don't trust random installation scripts online :). If there are issues with the installation scripts report it here ty. 

Clone the repository to copy and use these configuration files. 

```sh
git clone https://github.com/00Darxk/dotfiles.git
cd dotfiles
```

You can install either the english (```main-en```) or italian (```main```) tooltip version by switching branches and using the TUI installer.

# Installation

## Automatic (TUI Installer)

This repository includes an interactive TUI installer located in the `installer/` folder. It is a Rust application (`dotfiles-installer`) that provides a menu to run individual installation steps or a full installation. The installer calls functions from `install-functions.sh` (no legacy `install.sh`).

> [!IMPORTANT]
> The TUI installer uses `cargo` and `yay`. If you do not have them installed, you can install them with the commands below.

### Install Rust toolchain (rustup) – if needed

```bash
# Install rustup (Rust toolchain manager)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# After installation, ensure cargo is on your PATH
source "$HOME/.cargo/env"
```

### Install yay – if needed

```bash
# Install build tools
sudo pacman -S --needed git base-devel

# Clone and build yay from AUR
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
```

### Run the TUI installer

```bash
# From repo root
cd installer
cargo run --release
```

The TUI installer calls functions defined in `install-functions.sh`. At runtime it searches upwards from the current directory to find `install-functions.sh`, so it does not rely on a hardcoded path and works as long as you start it from somewhere inside the cloned repository. Audio sane-defaults (PipeWire/WirePlumber) are included in `pipewire/` and `wireplumber/`.

## Manual

Below a table of each package that should be installed, and its purpose. If you choose to install another package for the same purpose, you should also check the corresponding configuration files. 

### Dependencies

#### Pacman packages

| Package                   | Description |
| ------------------------- | ----------- |
| `hyprland`                | Hyprland compositor |
|| `warp-terminal`           | Default terminal |
| `waybar`                  | Customizable Wayland bar |
| `swaybg`                  | Used to set a desktop background image |
| `rofi-wayland`            | A window switcher, application launcher and dmenu replacement |
| `swaync`                  | Graphical notification daemon |
| `thunar`                  | Graphical file manager |
| `swayidle`                | Idle management deamon for Wayland |
| `ttf-jetbrains-mono-nerd` | Some nerd fonts for icons and overall look |
| `polkit-gnome`            | Graphical superuser, needed for some applications |
| `starship`                | Customizable shell prompt |
| `swappy`                  | Screenshot editor tool |
| `grim`                    | Screenshot tool, it grabs images from a Wayland compositor |
| `slurp`                   | Selects a region in a Wayland compositor, used to screenshot |
| `pamixer`                 | Pulseaudio command line mixer |
| `brightnessctl`           | Program to read and contro device brightness |
| `gvfs`                    | Adds missing feature to thunar |
| `bluez`                   | Bluetooth protocol stack |
| `bluez-utils`             | Command line utilities to interact with bluetooth devices |
| `blueman`                 | GTK+ bluetooth manager |
| `nwg-look`                | GTK3 settings editor adapter |
| `xfce4-settings`          | Set of tools for xfce, needed to set GTK theme |
| `xdg-desktop-portal-hyprland` | `xdg-desktop-portal` backend for hyprland |
| `wl-gammarelay`           | Client and daemon for changing color temperature and brightness under wayland |
| `hyfetch`                 | Fork of neofetch with LGBTQ+ pride flags. (Use your preferred neofetch fork) |
| `power-profiles-daemon`   | Maked power profiles handling over D-Bus |
| `sddm`                    | Login manager |
| `tff-fira-code`           | Free monospace font with programming ligatures |
| `tff-font-awesome`        | Icon font for waybar |
| `wol`                     | Wake-on-LAN tool for both CLI and web interfaces |
| `jq`                      | CLI JSON processor |
| `playerctl`               | MPRIS media player controller |
| `flameshot`               | Screenshot tool with GUI |
| `wl-clipboard`            | Wayland clipboard utilities |
| `btop`                    | Monitor of system resources |
| `telegram-desktop`        | Official Telegram Desktop client |
| `discord`                 | All-in-one voice and text chat for games |
| `steam`                   | Valve's digital software delivery system | 
| `spotify-launcher`        | Client for spotify's apt repository |
| `chromium`                | Web browser |
| `tailscale`               | Mesh VPN |
| `fzf`                     | CLI fuzzy finder |


```sh
pacman -S hyprland kitty waybar swaybg rofi-wayand swaync thunar swayidle ttf-jetbrains-mono-nerd polkit-gnome starship swappy grim slurp pamixer brightnessctl gvfs bluez bluez-utils blueman nwg-look xfce4-settings xdg-desktop-portal-hyprland wl-gammarelay hyfetch power-profiles-daemon sddm tff-fira-code tff-font-awesome wol jq playerctl flameshot wl-clipboard telegram-desktop discord steam spotify-launcher chromium tailscale fzf
```

#### AUR packages
|| Package | Description |
|| ------- | ----------- |
|| `wlogout`                 | Logout menu |
|| `swaylock-effects`        | Allow to lock the screen, fork that adds visual effects |
|| `swaylock-fancy`          | Swaylock with fancy effects |
|| `dracula-gtk-theme`       | Default theme |
|| `dracula-icons-git`       | Default icons |
|| `sddm-eucalyptus-drop`    | Sddm theme    |

```sh
yay -S wlogout swaylock-effects swaylock-fancy dracula-gtk-theme dracula-icons-git sddm-eucalyptus-drop
```

#### Optional Development & Communication Apps
|| Package | Description |
|| ------- | ----------- |
|| `intellij-idea-ultimate-edition` | IntelliJ IDEA Ultimate IDE for Java and other languages |
|| `slack-desktop`           | Team collaboration and messaging |
|| `teams-for-linux`         | Unofficial Microsoft Teams client |
|| `whatsapp-for-linux`      | Unofficial WhatsApp Desktop client |

```sh
yay -S intellij-idea-ultimate-edition slack-desktop teams-for-linux whatsapp-for-linux
```
Or your AUR helper of choice. 

#### Optional

Here is a list of useful and funny packages: 

| Package | Description |
| ------- | ----------- |
| `cowsay` | Configurable talking cow |
| `fortune-mod` | Fortune cookie program from BSG games |
| `pipes.sh`<sup>AUR</sup> | Animated pipes terminal screensaver |
| `figlet`      | A program for making large letters out of ordinary text | 
| `imagemagick` | An image viewing/manipulation program |
| `inkscape` | Professional vector graphics editor |
| `plasma-browser-integration`<sup>AUR</sup> | MPRIS support for browsers (enables YouTube Music in waybar) |

```sh
yay -S cowsay fortune-mod pipes.sh imagemagick inkscape
```

# Overview

## Hyprland

### Keybindings

You can check the keybinds in the [hyprland config](./hypr/hyprland.conf), or on the table below.

It contains explicit keybinds for F1 to F6 function keys, although they, and multimedia keys, should all work out of the box; if there are issues check your keyboard on the [wiki](https://wiki.archlinux.org/title/Extra_keyboard_keys), and bind them to the corresponding keys. 

<!-- | <kbd>FN1</kbd>                                 | Mute speaker |
| <kbd>FN2</kbd>                                 | Increase speaker volume |
| <kbd>FN3</kbd>                                 | Decrease speaker volume |
| <kbd>FN4</kbd>                                 | Mute microphone |
| <kbd>FN5</kbd>                                 | Decrease brightness |
| <kbd>FN6</kbd>                                 | Increase brightness | -->
| Keybind | Action |
| ------- | ------ |
| <kbd>XF86AudioPlay</kbd>                       | Play-pause current player |
| <kbd>XF86AudioPrev</kbd>                       | Go to next track on current player |
| <kbd>XF86AudioNext</kbd>                       | Go to previous track on current player |
|| <kbd>Ctrl</kbd>+<kbd>Alt</kbd>+<kbd>T</kbd>    | Open Warp terminal (alternative)                  |
|| <kbd>Super</kbd>+<kbd>Return</kbd>             | Open Warp terminal                                |
|| <kbd>Super</kbd>+<kbd>E</kbd>                  | Open Thunar file manager                          |
|| <kbd>Super</kbd>+<kbd>Q</kbd>                  | Kill active window                                |
|| <kbd>Super</kbd>+<kbd>L</kbd>                  | Lock the screen                                   |
|| <kbd>Super</kbd>+<kbd>O</kbd>                  | Reload waybar                                     |
|| <kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>M</kbd> | Exit Hyprland environment                         |
|| <kbd>Super</kbd>+<kbd>V</kbd>                  | Toggle floating for active window                 |
|| <kbd>Super</kbd>+<kbd>F</kbd>                  | Toggle fullscreen                                 |
|| <kbd>Super</kbd>+<kbd>Y</kbd>                  | Pin window (shows on all workspaces)              |
|| <kbd>Super</kbd>+<kbd>J</kbd>                  | Toggle split                                      |
|| <kbd>Super</kbd>+<kbd>K</kbd>                  | Toggle group mode                                 |
|| <kbd>Super</kbd>+<kbd>Tab</kbd>                | Switch to next window in group                    |
|| <kbd>Super</kbd>+<kbd>Space</kbd>              | Show the app launcher (rofi)                      |
|| <kbd>Print</kbd>                               | Screenshot region                                 |
|| <kbd>Ctrl</kbd>+<kbd>Print</kbd>               | Screenshot active window                          |
|| <kbd>Alt</kbd>+<kbd>Print</kbd>                | Screenshot entire screen                          |
|| <kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>S</kbd> | Flameshot GUI                                     |
|| <kbd>Super</kbd>+<kbd>G</kbd>                  | Remove gaps between windows                       |
|| <kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>F[1-9]</kbd> | Launch apps: Thunar(F1), WhatsDesk(F2), Chromium(F3), Discord(F4), Telegram(F5), Steam(F6), VSCodium(F8), Spotify(F9) |
|| <kbd>Super</kbd>+<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>0</kbd> | Reset screen temperature to 6500K      |
|| <kbd>Super</kbd>+<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>↑</kbd> | Increase screen temperature (+500K)    |
|| <kbd>Super</kbd>+<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>↓</kbd> | Decrease screen temperature (-500K)    |
|| <kbd>Super</kbd>+<kbd>R</kbd>                  | Activate resize mode                              |
|| <kbd>Super</kbd>+<kbd>←→↑↓</kbd>               | Move focus through windows                        |
|| <kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>←→↑↓</kbd> | Move window                                   |
|| <kbd>Super</kbd>+<kbd>[1-9,0]</kbd>            | Switch to workspace 1-10                          |
|| <kbd>Super</kbd>+<kbd>Ctrl</kbd>+<kbd>[1-9,0]</kbd> | Move window and switch to workspace         |
|| <kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>[1-9,0]</kbd> | Move window silently to workspace          |
|| <kbd>Super</kbd>+<kbd>Period</kbd>             | Next workspace                                    |
|| <kbd>Super</kbd>+<kbd>Comma</kbd>              | Previous workspace                                |

> Flameshot on Wayland/Hyprland: the session exports `FLAMESHOT_WAYLAND=1` and `QT_QPA_PLATFORM=wayland`, and `flameshot/flameshot.ini` enables the grim adapter to fix multi-monitor placement and scaling. If you copy these dotfiles to `~/.config`, Flameshot will launch in native Wayland mode and the capture region will match both monitors correctly.
|| <kbd>Super</kbd>+<kbd>Slash</kbd>              | Switch to previous workspace                      |
|| <kbd>Super</kbd>+<kbd>Minus</kbd>              | Move to special workspace                         |
|| <kbd>Super</kbd>+<kbd>Equal</kbd>              | Toggle special workspace                          |
|| <kbd>Super</kbd>+<kbd>F1</kbd>                 | Toggle scratchpad                                 |
|| <kbd>Super</kbd>+<kbd>Scroll↑↓</kbd>           | Scroll through workspaces                         |
|| <kbd>Super</kbd>+<kbd>LMB</kbd>                | Move window with dragging                         |
|| <kbd>Super</kbd>+<kbd>RMB</kbd>                | Resize window with dragging                       |
### Wallpapers

<div class="grid" markdown>

![1](./showcases/moon-over-mondstat-showcase.png)

![1](./showcases/sucrose-showcase.png)

![1](./showcases/sayu-showcase.png)

![1](./showcases/xiao-showcase.png)

</div>

Credit to [Shade of a cat](https://shadeofacat.carrd.co/) and [Sevenics](https://www.deviantart.com/sevenics) for the amazing art! 
> [!NOTE]
> I don't remember why I converted all the backgrounds from png to jpg, it should work either way. Too lazy to check the wiki. 

To add a new wallpaper to hyprland, add a line at the end of the [hyprland.conf](./hypr/hyprland.conf) file, specifying the location of the image. 
To set it at start, change the location of the exec call inside the [config](./hypr/hyprland.conf) to the background image. 

In the same way you can edit the top line of the [swaylock config](./swaylock/config) to change the background image. 

## Waybar 
<!-- TODO add module description, link to wiki -->
### Default Modules

### Hyprland Modules

### Wake on LAN and Tailscale Module
If you'd like to use the waybar module to wake a machine over LAN either follow the instructions in the installation scripts or create the ```./secrets``` folder, the ```ip-address.txt``` and ```mac-address.txt``` files.

The [wol.sh](./waybar/scripts/wol.sh) sends a magic packet to the machine, using the [wol](https://sourceforge.net/projects/wake-on-lan/) package. Change the script if you would like to use a different application. 

 the same module can be used to ssh into another machine using tailscale, for this create the ```hostname.txt``` file inside the secret folder with the hostname or the ip address in your tailscale network. For simplicity both these functions refer to the same machine. 
You can just comment out or remove the module in [waybar config](./waybar/config.jsonc) if you don't use it. If you haven't configured it, it will not show in waybar. 

To WoL left-click the module, to ssh right-click it; the color of the module shows the tailscale status of the machine you configured, not if the machine itself is on or off. If you have enabled tailscaled on the machine it will show the machine status, as it starts on startup. If you have set different machines for WoL and ssh the tooltip refers only to the ssh machine.

### GitHub Notifications Module

Instructions in the waybar [wiki](https://github.com/Alexays/Waybar/wiki/Module:-Custom:-Simple#github-notifications). Place the ```notifications.token``` inside the ```.secrets``` folder. 

## Wlogout

This configuration is *almost* entirely taken from [klpod0s](https://github.com/klpod221/klpod0s), an aestethic, dynamic and minimal configuration for hyprland; just changed the color theme and tweaked a bit. 

## Rofi

This configuration is taken, and edited, from [adi1090's rofi collection](https://github.com/adi1090x/rofi). 

## Themes

I tried to base it off this [color scheme](https://color.adobe.com/it/olor-Theme-color-theme-18068611/), but I'm not really good with that, if someone who knows colors could help I'd be very thankful :). 

I use [squared theme](https://www.gnome-look.org/p/2206255) for gtk, and [ant-dark](https://store.kde.org/p/1640981/) icons theme. To add themes and icon themes download and unzip theme respectively in ```~/.themes``` and ```~/.local/share/icons```, use this last directory to store cursor icons (i use my oshi [Rin Penrose](https://www.gnome-look.org/p/2260618)'s)

For `sddm` I use the [eucalyptus-drop](https://gitlab.com/Matt.Jolly/sddm-eucalyptus-drop) theme, it is available on the AUR and can be installed via your AUR helper (for example `yay -S sddm-eucalyptus-drop`). 

