#!/usr/bin/env bash

# Waybar custom module: per-output wl-gammarelay-rs color temperature.
#
# wl-gammarelay-rs (unlike the plain wl-gammarelay it replaces) exposes each
# output separately at /outputs/<NAME>, with '-' swapped for '_' since D-Bus
# object paths can't contain hyphens (e.g. Hyprland's "DP-4" -> "DP_4"). The
# root path "/" still works as a global fallback -- it reports the average
# across all outputs, which is exactly the old single-value behavior and is
# fine on a machine with only one display.
#
# Usage: gammarelay-temperature.sh <get|inc|dec> <dbus object path>
#   e.g. gammarelay-temperature.sh get /outputs/DP_4
#        gammarelay-temperature.sh get /            (global fallback)

set -euo pipefail

action="$1"
path="$2"

case "$action" in
    get)
        value=$(busctl --user get-property rs.wl-gammarelay "$path" rs.wl.gammarelay Temperature 2>/dev/null | awk '{print $2}') || {
            printf '{"text":"N/A","tooltip":"wl-gammarelay-rs unavailable"}\n'
            exit 0
        }
        printf '{"text":"%s K","tooltip":"Screen Temperature: %s K"}\n' "$value" "$value"
        ;;
    inc)
        busctl --user call rs.wl-gammarelay "$path" rs.wl.gammarelay UpdateTemperature n 100 >/dev/null 2>&1 || true
        ;;
    dec)
        busctl --user call rs.wl-gammarelay "$path" rs.wl.gammarelay UpdateTemperature n -- -100 >/dev/null 2>&1 || true
        ;;
    *)
        echo "Usage: $0 {get|inc|dec} <dbus object path>" >&2
        exit 1
        ;;
esac
