#!/bin/bash

# This code is almost entirely taken from Mr. Cejas's blog: https://fernandocejas.com/blog/engineering/2022-03-30-arch-linux-system-maintance/
echo "Updating system"
shelly upgrade all

# `purify standard` folds what used to be two separate tools into one pass:
# --orphans drops packages nothing depends on any more (was `yay -Qdtq | yay -Rns -`)
# and --cache trims the package cache down to the last 3 versions (was paccache -r).
echo "Removing orphan packages and trimming the package cache"
pacman_cache_space_used="$(du -sh /var/cache/pacman/pkg/)"
shelly purify standard --orphans --cache 3
echo "Cache was using: $pacman_cache_space_used"

echo "Clearing ~/.cache"
home_cache_used="$(du -sh ~/.cache)"
rm -rf ~/.cache/
echo "Spaced saved: $home_cache_used"

echo "Clearing system logs"
journalctl --vacuum-time=7d
