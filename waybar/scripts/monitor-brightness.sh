#!/usr/bin/env bash

# Waybar custom module: DDC/CI monitor brightness (external displays).
# ddcutil talks VCP 10 (Brightness) over the DisplayPort/HDMI AUX channel --
# this is real hardware backlight control, the same thing a monitor's own
# OSD buttons do, distinct from the Linux "backlight" sysfs class (which
# only exists for internally-wired panels and doesn't apply to external
# monitors at all).
#
# Usage: monitor-brightness.sh <get|inc|dec> <ddcutil monitor selector...>
#   e.g. monitor-brightness.sh get --model "Kamvas Pro 13"
#        monitor-brightness.sh inc --sn 107NTUW5C662

set -euo pipefail

action="$1"; shift

case "$action" in
    get)
        line=$(ddcutil getvcp 10 --terse "$@" 2>/dev/null) || {
            printf '{"text":"N/A","tooltip":"DDC/CI brightness unavailable"}\n'
            exit 0
        }
        read -r _ _ _ current max <<< "$line"
        pct=$(( current * 100 / max ))
        printf '{"text":"%s%%","tooltip":"Monitor brightness: %s%%"}\n' "$pct" "$pct"
        ;;
    inc)
        ddcutil setvcp 10 + 5 "$@" >/dev/null 2>&1 || true
        ;;
    dec)
        ddcutil setvcp 10 - 5 "$@" >/dev/null 2>&1 || true
        ;;
    *)
        echo "Usage: $0 {get|inc|dec} -- <ddcutil selector>" >&2
        exit 1
        ;;
esac
