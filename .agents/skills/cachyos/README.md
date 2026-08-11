# CachyOS Skill

An agent skill for managing [CachyOS](https://cachyos.org/) systems through natural language. Modeled after [robzolkos/omarchy-skill](https://github.com/robzolkos/omarchy-skill) but rewritten for CachyOS: optimized repos, the CachyOS kernel family, `chwd`, `cachyos-rate-mirrors`, automatic BTRFS snapshots via `snap-pac`, and the `cachyos-*` toolchain.

CachyOS is Arch underneath, so the skill stays out of the way of Arch fundamentals and only documents what's *different*.

## What it covers

- Optimized `cachyos-v3` / `cachyos-v4` repos and the `cachyos-hooks` machinery
- CachyOS kernels (`linux-cachyos`, `-lts`, `-bore`, `-bmq`, `-eevdf`, `-hardened`, `-rt`, `-sched-ext`, `-deckify`, `-nvidia-open`) + `cachyos-kernel-manager`
- `chwd` for GPU / hardware driver profiles
- `cachyos-rate-mirrors` and the auto-rating pacman hook
- BTRFS snapshots: `snapper` + `snap-pac` (pre/post pacman transaction)
- `ananicy-cpp` + `cachyos-ananicy-rules`
- `paru` / `yay` AUR helpers
- The user's Hyprland dotfiles layered on top of CachyOS

The skill itself lives under `.agents/skills/cachyos` — a tool-agnostic location, since
it's just markdown. Each agent tool symlinks it into wherever it looks for skills.

## Install (Claude Code)

```bash
git clone https://github.com/00Darxk/dotfiles.git ~/dotfiles
ln -s ~/dotfiles/.agents/skills/cachyos ~/.claude/skills/cachyos
```

Or, if you don't want to clone the whole dotfiles repo, copy just the skill:

```bash
mkdir -p ~/.claude/skills/cachyos
cp /path/to/dotfiles/.agents/skills/cachyos/SKILL.md ~/.claude/skills/cachyos/
```

## Install (OpenCode)

```bash
ln -s ~/dotfiles/.agents/skills/cachyos ~/.config/opencode/skill/cachyos
```

## Install (other tools)

Any tool that reads skills as a directory of `SKILL.md` files can point at
`.agents/skills/cachyos` the same way — symlink it into that tool's own skills
directory.

## Verify

In a fresh Claude Code session inside this repo (or with the skill symlinked into `~/.claude/skills/`), ask something CachyOS-specific:

> "How do I switch to the LTS kernel?"

The agent should reference `cachyos-kernel-manager` and the `linux-cachyos-lts` package, not a generic Arch answer.

## Requirements

- A CachyOS system (`/etc/os-release` reports `ID=cachyos`)
- Claude Code or OpenCode with skill support

## Credit

Structure and "discovery-based" framing inspired by [robzolkos/omarchy-skill](https://github.com/robzolkos/omarchy-skill).
