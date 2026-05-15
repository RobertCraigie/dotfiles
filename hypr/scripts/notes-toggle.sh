#!/usr/bin/env bash
set -euo pipefail

NOTES_FILE="$HOME/notes.md"

has_notes_window() {
    hyprctl clients -j | grep -q '"class": "notes"'
}

if has_notes_window; then
    hyprctl dispatch togglespecialworkspace notes
    exit 0
fi

NVIM_NOTES=1 kitty \
    --class notes \
    --override tab_bar_min_tabs=999 \
    -e nvim \
    -c "set laststatus=0 showtabline=0 cmdheight=0 ruler! showmode!" \
    "$NOTES_FILE" &
disown
