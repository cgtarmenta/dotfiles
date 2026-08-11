---
name: cachyos
description: Manage and configure CachyOS Linux systems. Use when the user asks about CachyOS, optimized repos (v3/v4), the CachyOS kernel, chwd, cachyos-rate-mirrors, BTRFS snapshots via snapper/snap-pac, or any cachyos-* command.
---

# CachyOS Skill

Manage [CachyOS](https://cachyos.org/) — a performance-tuned Arch derivative — using natural language.

CachyOS is Arch underneath. **Anything that works on Arch works here.** This skill covers what is *different*: the CachyOS toolchain, optimized repos, custom kernels, automatic BTRFS snapshots, and the few `cachyos-*` / `chwd` commands.

## ⛔ NEVER MODIFY PACKAGE-OWNED FILES

**DO NOT edit, write, or delete files under `/usr/share/cachyos-*/`, `/usr/lib/`, or other package-owned paths.** They are overwritten on update.

User configuration belongs in:
- `~/.config/<app>/` for per-user settings
- `/etc/<app>/` for system-wide overrides (use drop-ins like `/etc/sysctl.d/99-local.conf` rather than editing CachyOS-shipped files)
- `~/.zshrc.d/` or `~/.config/fish/conf.d/` to extend the CachyOS shell configs without touching them

If a CachyOS-shipped tweak needs to change, override it with a higher-numbered file in the same `.d/` directory.

## Discovery

```bash
# List CachyOS-specific commands installed on this system
compgen -c | grep -E '^(cachyos-|chwd|paru$|yay$)' | sort -u

# Read a command's source / package
pacman -Qo "$(which cachyos-rate-mirrors)"
pacman -Ql cachyos-settings | grep -E '\.(conf|rules|service)$'

# What CachyOS packages are installed
pacman -Qs cachyos
```

## What makes CachyOS different from stock Arch

| Feature | Package | Notes |
|---------|---------|-------|
| Optimized repos | `cachyos-v3-mirrorlist`, `cachyos-v4-mirrorlist` | x86_64-v3/v4 prebuilt packages, BORE-LLVM compiled |
| Custom kernel | `linux-cachyos`, `-lts`, `-bore`, `-bmq`, `-eevdf`, `-hardened`, `-rt`, `-rt-bore`, `-sched-ext`, `-deckify`, `-nvidia-open` | Default ships with BORE scheduler |
| Hardware detection | `chwd` | Detects GPU/Wi-Fi/etc and installs the right driver profile |
| Mirror ranking | `cachyos-rate-mirrors` | Wraps `rate-mirrors` for the CachyOS repos |
| Settings/tweaks | `cachyos-settings` | sysctl, udev rules, modprobe.d defaults |
| Pacman hooks | `cachyos-hooks` | Repo selection, branding, mirror-rate triggers |
| Auto BTRFS snapshots | `cachyos-snapper-support` + `snap-pac` | Pre/post snapshot on every pacman transaction |
| Process priority | `cachyos-ananicy-rules` + `ananicy-cpp` | Auto-renices apps by category |
| GUIs | `cachyos-kernel-manager`, `cachyos-packageinstaller` (`cachyos-pi`), `cachyos-hello` | Optional |

## Optimized Repos (v3 / v4)

CachyOS ships separate Pacman repos with packages compiled for newer x86_64 micro-architectures.

```bash
# Check which level your CPU supports (v3, v4, etc.)
/lib/ld-linux-x86-64.so.2 --help | grep -E 'x86-64-v[234]'

# See which repos are active
grep -E '^\[cachyos' /etc/pacman.conf
```

Repo selection is normally handled automatically by the `cachyos-hooks` package. **Do not manually rewrite `/etc/pacman.conf` blocks for these repos** — reinstall `cachyos-v3-mirrorlist` / `cachyos-v4-mirrorlist` instead and let the post-install hook regenerate them.

Wiki: <https://wiki.cachyos.org/features/optimized_repos/>

## Kernels

```bash
# List installed kernels
pacman -Q | grep -E '^linux-cachyos' | grep -v headers

# Switch kernel — GUI
cachyos-kernel-manager

# Switch kernel — CLI (also pulls headers for DKMS)
sudo pacman -S linux-cachyos-lts linux-cachyos-lts-headers
# then reboot

# Pick which kernel boots by default (GRUB on this system)
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Wiki: <https://wiki.cachyos.org/features/kernel/> · <https://wiki.cachyos.org/features/kernel_manager/>

## Hardware Drivers — `chwd`

`chwd` (CachyOS Hardware Detection) is the CachyOS replacement for `mhwd`. It installs driver profiles based on detected hardware.

```bash
chwd --list                  # profiles available for your hardware
chwd --list-all              # every profile in the database
sudo chwd -a                 # auto-configure all detected devices
sudo chwd -i nvidia-open     # install a specific profile
sudo chwd -r nvidia          # remove a profile
chwd -d --list               # show detailed info
```

GPU migration (e.g. proprietary → open NVIDIA): <https://wiki.cachyos.org/features/chwd/gpu_migration/>

## Mirrors

```bash
sudo cachyos-rate-mirrors    # rate Arch + CachyOS mirrors, write new mirrorlists
```

This runs on every `pacman -Syu` via the `cachyos-rate-mirrors.hook` pacman hook. Manual invocation is only needed when downloads feel slow.

## BTRFS Snapshots (snapper + snap-pac)

If installed on BTRFS with the default layout, snapshots happen automatically:
- `05-snap-pac-pre.hook` → pre-transaction snapshot
- `zz-snap-pac-post.hook` → post-transaction snapshot

```bash
sudo snapper -c root list                     # list snapshots
sudo snapper -c root create -d "before X"     # manual snapshot
sudo snapper -c root undochange A..B          # roll back files between two snapshots
sudo snapper -c root delete N                 # delete snapshot N
```

GRUB on this system reads `/.snapshots` via `grub-btrfs` (if installed) so older snapshots can be booted from the boot menu.

Wiki: <https://wiki.cachyos.org/configuration/btrfs_snapshots/>

## Package Management

CachyOS ships **both** `paru` and `yay` as AUR helpers.

```bash
sudo pacman -Syu               # system + AUR-free update
paru -Syu                      # update including AUR (preferred on CachyOS)
paru -S <pkg>                  # install from repos or AUR
paru -Rns <pkg>                # remove with deps + config
paru -Qtdq | paru -Rns -        # remove orphans

cachyos-pi                     # GUI package installer (curated lists)
```

## Performance: ananicy-cpp

`ananicy-cpp` auto-renices known processes using `cachyos-ananicy-rules`.

```bash
systemctl status ananicy-cpp
sudo systemctl restart ananicy-cpp     # after editing/adding rule files
```

Custom rules: drop a `.rules` file in `/etc/ananicy.d/00-local/` (create the dir if needed) — do NOT edit `/usr/share/ananicy/`.

## Shells

This system runs **Hyprland** with `/bin/zsh` as the login shell and `/bin/fish` configured for the agent harness. CachyOS provides opinionated configs:

- `cachyos-zsh-config` → `/etc/skel/.zshrc` + `/usr/share/cachyos-zsh-config/`
- `cachyos-fish-config` → `/usr/share/cachyos-fish-config/`

Extend without touching the shipped files:
- zsh: source extra files from `~/.zshrc.d/` (or just append at the bottom of `~/.zshrc`)
- fish: drop `*.fish` files in `~/.config/fish/conf.d/`

## Troubleshooting

```bash
cachyos-bugreport.sh          # collect system info for bug reports
paste-cachyos <file>          # upload to CachyOS paste service
journalctl -b -p err          # boot errors
inxi -Faz                     # full hardware report
```

If something CachyOS-specific is broken, capture output with `cachyos-bugreport.sh` *before* trying fixes.

## This Repo's Setup (Hyprland Dotfiles)

The user runs Hyprland on top of CachyOS using the configs in this repo. **CachyOS does not own the Hyprland config.** For Hyprland/Waybar/Kitty changes, edit the files under this repo's `hypr/`, `waybar/`, `kitty/`, etc. directories, *not* anything CachyOS-owned.

- Apply Hyprland config changes: `hyprctl reload`
- Reload Waybar: `~/.config/waybar/scripts/launch.sh` (bound to <kbd>Super</kbd>+<kbd>O</kbd>)
- Audio defaults (PipeWire/WirePlumber) live in this repo's `pipewire/` and `wireplumber/` directories

See `README.md` and `WARP.md` at the repo root for the full keybinding map and waybar module list.

## Safe Editing Pattern

1. **Read** the current file: `cat <path>`
2. **Back up** if it's a system file: `sudo cp <path> <path>.bak.$(date +%s)`
3. **Prefer a drop-in** to editing in place. Examples:
   - sysctl: `/etc/sysctl.d/99-local.conf`
   - udev: `/etc/udev/rules.d/99-local.rules`
   - pacman: never; reinstall the mirrorlist package instead
4. **Apply**: reload the daemon (`systemctl reload <unit>`) or run the matching `cachyos-*` refresh command. For kernel/initramfs changes, rebuild: `sudo mkinitcpio -P`.
5. **Explain** what changed and why in a short "Learn More" note to the user.

## CachyOS Wiki

For anything not covered here, fetch the relevant wiki page before answering. Topic index:

| Topic | URL |
|-------|-----|
| Why CachyOS / FAQ | <https://wiki.cachyos.org/cachyos_basic/why_cachyos/> · <https://wiki.cachyos.org/cachyos_basic/faq/> |
| Post-install setup | <https://wiki.cachyos.org/configuration/post_install_setup/> |
| General system tweaks | <https://wiki.cachyos.org/configuration/general_system_tweaks/> |
| Optimized repos (v3/v4) | <https://wiki.cachyos.org/features/optimized_repos/> |
| CachyOS settings package | <https://wiki.cachyos.org/features/cachyos_settings/> |
| CachyOS kernel / scheduler | <https://wiki.cachyos.org/features/kernel/> · <https://wiki.cachyos.org/configuration/sched-ext/> |
| Kernel manager | <https://wiki.cachyos.org/features/kernel_manager/> |
| chwd / GPU migration | <https://wiki.cachyos.org/features/chwd/chwd/> · <https://wiki.cachyos.org/features/chwd/gpu_migration/> |
| Dual GPU | <https://wiki.cachyos.org/configuration/dual_gpu/> |
| BTRFS snapshots | <https://wiki.cachyos.org/configuration/btrfs_snapshots/> |
| Boot manager configuration | <https://wiki.cachyos.org/configuration/boot_manager_configuration/> |
| Secure Boot | <https://wiki.cachyos.org/configuration/secure_boot_setup/> |
| Gaming | <https://wiki.cachyos.org/configuration/gaming/> |
| Switch desktop environment | <https://wiki.cachyos.org/configuration/desktop_environments/switch_desktop/> |
| Virtualization (QEMU/VFIO) | <https://wiki.cachyos.org/virtualization/qemu_and_vmm_setup/> |
| Cachy-chroot (recovery) | <https://wiki.cachyos.org/features/cachy_chroot/> |
| Handheld install | <https://wiki.cachyos.org/installation/installation_handheld/> |

For pure Arch topics (pacman, systemd, networking, AUR mechanics) prefer the Arch Wiki: <https://wiki.archlinux.org/>.

## Example Requests

- "Switch me to the LTS kernel"
- "My v4 repo isn't being used — check it"
- "Rate the mirrors, downloads are slow"
- "Install the open-source NVIDIA driver"
- "Take a snapper snapshot before this upgrade, then run it"
- "Add a sysctl override to increase inotify watches"
- "Why is `ananicy-cpp` not picking up my custom rule?"
- "Boot into the previous BTRFS snapshot"
- "Generate a CachyOS bug report"
