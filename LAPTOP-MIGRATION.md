# Checklist: moving the ROG Flow X13 from `rog-flow` to `main`

One-time checklist for the day you have the laptop in front of you. `origin/rog-flow`
is **not** touched by this — it stays as-is, permanently, as a rollback path. This is
about deploying the unified `main` branch to the laptop alongside it.

## 0. Before touching anything

- [ ] On the laptop, in the existing dotfiles clone: `git status` and `git diff` —
      specifically check `waybar/` for uncommitted changes. There's a "better
      temperature icon" Tadeo remembers seeing on the laptop that was never found
      in any commit on `main` or `rog-flow` — if it's sitting there uncommitted,
      decide whether to bring it into `main` before overwriting anything.
- [ ] Note which branch is currently checked out and whether `rog-flow` there is
      up to date with `origin/rog-flow`.
- [ ] Do this on a fresh clone or a new worktree first if there's any doubt about
      losing local state — don't `git checkout main` directly over a dirty
      `rog-flow` checkout.

## 1. Decide the idle-daemon strategy

`origin/rog-flow` has `hypridle.conf` + `ac-power-idle-toggle.sh` + the
`custom/ac_idle_mode` Waybar widget (AC-connected idle lock/suspend override).
`main` only has `swayidle`. These weren't merged into `main` on purpose — running
both daemons at once is not something to default into.

- [ ] Decide: keep `swayidle` for both machines, switch both to `hypridle`, or run
      `hypridle` only on the laptop.
- [ ] If porting `hypridle`/`ac-power-idle-toggle.sh`/`ac_idle_mode` into `main`:
      do it as its own branch + PR, same as everything else in this migration.

## 2. Install `waybar-git`

The stable `waybar` package (0.15.0) hardcodes the old `hyprctl dispatch workspace
<id>` call, which breaks under `hyprland.lua` (Hyprland's Lua dispatch protocol
expects `hl.dsp.focus({workspace=<id>})`) — clicking workspace numbers does nothing.
Fixed upstream in Waybar's PR #5013, merged to master, not yet in a stable release
as of 2026-08-10. Same fix needed on the laptop:

```bash
yay -S waybar-git --noconfirm
# if pacman balks on the waybar/waybar-git conflict instead of resolving it:
sudo pacman -R waybar --noconfirm
sudo pacman -U ~/.cache/yay/waybar-git/waybar-git-*.pkg.tar.zst --noconfirm
```

- [ ] Confirm: `pacman -Q waybar-git` shows the installed version.

## 3. Deploy `main`

- [ ] `git checkout main && git pull` in the laptop's clone.
- [ ] Run the installer (`cd installer && cargo run --release`, "Deploy Configuration
      Files") or manually: `source install-functions.sh && deploy_configs`.
  - This now symlinks (`ln -sf`), not copies — it'll offer a backup for anything
    real (non-symlink) it's about to replace. Say yes.
- [ ] Confirm every item under `~/.config/` (`hypr`, `waybar`, `kitty`, `pipewire`,
      `wireplumber`, etc.) is a symlink into the repo: `ls -la ~/.config/`.

## 4. Activate `hyprland.lua` — the part that needs care

Hyprland decides `.conf` vs `.lua` **once, at process startup** — not on
`hyprctl reload`. On the desktop, symlinking `hypr/` while Hyprland was already
running caused it to auto-generate a stub `hyprland.conf` (it watches the config
path and writes a minimal fallback the moment the file it expects goes missing),
which briefly wiped monitors/keyboard/binds and, because the directory was a
symlink, got written straight into the git repo.

- [ ] Only symlink `hypr/` (or run the full deploy) immediately before an
      already-planned logout/restart — not hours before. If Hyprland is about to
      die anyway, the transient stub doesn't matter.
- [ ] After symlinking, confirm `~/.config/hypr/` contains only `hyprland.lua`
      (no `hyprland.conf` alongside it) right before restarting.
- [ ] Log out and back in (or fully restart Hyprland) — not just `hyprctl reload`.
- [ ] After login: `hyprctl configerrors` should be empty. Check monitors
      (`hyprctl monitors`), keyboard layout, and that `swaybg`/`swaync`/
      `wl-gammarelay` are running (`pgrep -a swaybg` etc.) — if the wallpaper is
      missing, something regressed on the "runs at startup" wiring that was
      already fixed once for the desktop.
- [ ] Test clicking a workspace number in Waybar (needs `waybar-git` from step 2).

## 5. What's deliberately different from `rog-flow`

Don't be surprised by these — they're intentional, not bugs:

- No `custom/asus_profile` widget. It duplicated the native `power-profiles-daemon`
  module already in `main`'s `modules.jsonc`.
- No `custom/ac_idle_mode` widget yet — see step 1.
- `backlight` no longer hardcodes a device name (`intel_backlight` /
  `amdgpu_bl2`) — Waybar auto-detects it. Should just work; if it doesn't, check
  `ls /sys/class/backlight/`.
- `custom/asus_gpu_mode` only appears if `supergfxctl` is installed
  (`exec-if: "command -v supergfxctl"`).

## 6. Rollback

`origin/rog-flow` is untouched and still fully deployable if anything here doesn't
work out — nothing in this checklist changes that branch.
