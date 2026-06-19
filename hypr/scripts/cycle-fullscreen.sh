#!/usr/bin/env bash
# Cycle focus; if the previously active window was fullscreen, fullscreen the new one too.
set -euo pipefail

WAS_FS=$(hyprctl activewindow -j | jq -r '.fullscreen')

if [[ "${1:-}" == "prev" ]]; then
    hyprctl dispatch cyclenext prev
else
    hyprctl dispatch cyclenext
fi

if [[ "$WAS_FS" != "0" && "$WAS_FS" != "false" ]]; then
    hyprctl dispatch fullscreenstate 2
fi
