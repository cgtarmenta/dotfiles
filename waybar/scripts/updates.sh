#!/bin/bash

threshhold_yellow=15
threshhold_red=100

# -------------------------------------------------------
# Count available updates across every backend shelly manages
# (repositories, AUR, Flatpak, AppImage) in a single query.
# -------------------------------------------------------

# `list-updates all --json` returns one array per backend:
#   {"Packages": [...], "Aur": [...], "Flatpak": [...], "AppImage": [...]}
# each entry carrying Name, CurrentVersion and NewVersion. One call replaces the
# old checkupdates + `yay -Qua` pair, and it cannot half-fail the way those could.
updates_json=$(shelly list-updates all --json 2>/dev/null)

if [ -z "$updates_json" ]; then
    printf '{"text": "0", "alt": "0", "tooltip": "Update System\\n<span size=\\"small\\">unavailable</span>", "class": "green"}\n'
    exit 0
fi

# -------------------------------------------------------
# Output in JSON format for Waybar Module custom-updates
# -------------------------------------------------------
# jq builds the whole payload: it escapes the JSON for us (the tooltip is a
# multi-line string, which hand-rolled quoting kept getting wrong) and -c keeps it
# on the one line Waybar reads per poll. The arrow is U+2192 rather than "->" so
# the Pango markup in the tooltip needs no extra escaping beyond & < > below.
jq -c \
    --argjson yellow "$threshhold_yellow" \
    --argjson red "$threshhold_red" '
    def pango: gsub("&"; "&amp;") | gsub("<"; "&lt;") | gsub(">"; "&gt;");

    [.Packages, .Aur, .Flatpak, .AppImage] as $backends
    | ($backends | map(length) | add // 0) as $count
    | ($backends
        | map(.[]? | "\(.Name) \(.CurrentVersion) → \(.NewVersion)" | pango)
        | flatten) as $lines
    | {
        text: ($count | tostring),
        alt: ($count | tostring),
        tooltip: ("Update System\n<span size=\"small\">\($count) Packages</span>:\n"
                  + ($lines | join("\n"))),
        class: (if $count > $red then "red"
                elif $count > $yellow then "yellow"
                else "green" end)
      }
' <<< "$updates_json"
