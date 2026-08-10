#!/bin/bash

# Right-click on the updates widget. `shelly list standard` prints a formatted
# table, so go through --json for the names and let shelly render the detail view
# in the preview pane.
shelly list standard --json |
    jq -r '.[].Name' |
    fzf --preview 'shelly search standard --installed --detail {}' \
        --layout=reverse \
        --bind 'enter:execute(shelly search standard --installed --detail {} | less)'
