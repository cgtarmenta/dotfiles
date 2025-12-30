#!/usr/bin/env bash

# Simple Waybar JSON output for current ASUS performance profile
# Requires: asusctl, powerprofilesctl

set -euo pipefail

# Try powerprofilesctl first (system-wide), fall back to asusctl
if command -v powerprofilesctl >/dev/null 2>&1; then
  profile=$(powerprofilesctl get 2>/dev/null || echo "unknown")
else
  profile=$(asusctl profile -p 2>/dev/null | sed -n 's/^Profile: //p' | head -n1)
fi

case "$profile" in
  performance|Performance)
    ICON=""
    LABEL="Perf"
    ;;
  balanced|Balanced|balanced-performance)
    ICON=""
    LABEL="Bal"
    ;;
  power-saver|Quiet|quiet)
    ICON=""
    LABEL="Eco"
    ;;
  *)
    ICON="󰣇"
    LABEL="?"
    ;;
fi

printf '{"text": "%s", "alt": "%s"}\n' "$LABEL" "$ICON"
