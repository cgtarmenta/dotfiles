#!/usr/bin/env bash

# Waybar JSON output for current GPU mode on ASUS ROG (supergfxctl)

set -euo pipefail

if ! command -v supergfxctl >/dev/null 2>&1; then
  printf '{"text": "N/A", "alt": "N/A"}\n'
  exit 0
fi

mode=$(supergfxctl -g 2>/dev/null | tr 'A-Z' 'a-z')

case "$mode" in
  hybrid)
    LABEL="Hyb"
    ICON="󰢮"
    ;;
  integrated)
    LABEL="iGPU"
    ICON="󰢮"
    ;;
  dedicated)
    LABEL="dGPU"
    ICON="󰢮"
    ;;
  vfio)
    LABEL="VFIO"
    ICON="󰢮"
    ;;
  *)
    LABEL="?"
    ICON="󰢮"
    ;;
fi

printf '{"text": "%s", "alt": "%s"}\n' "$LABEL" "$ICON"
