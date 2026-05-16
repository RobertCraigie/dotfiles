#!/usr/bin/env bash
set -euo pipefail

class=$(hyprctl -j activewindow | jq -r '.class // empty')

case "$class" in
    kitty|org.wezfurlong.wezterm|Alacritty|alacritty|foot|footclient|com.mitchellh.ghostty|st-256color|xterm-256color|wezterm)
        hyprctl dispatch sendshortcut "CTRL SHIFT, C, activewindow" >/dev/null
        ;;
    *)
        hyprctl dispatch sendshortcut "CTRL, C, activewindow" >/dev/null
        ;;
esac
