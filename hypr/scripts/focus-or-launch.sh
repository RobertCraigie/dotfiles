#!/usr/bin/env bash
# Focus the most-recently-used window of CLASS, or launch it if none exist.
set -euo pipefail

CLASS="$1"
shift
if [[ $# -eq 0 ]]; then
    set -- "$CLASS"
fi

ADDR=$(hyprctl clients -j \
    | jq -r --arg c "$CLASS" \
        '[.[] | select(.class == $c)] | sort_by(.focusHistoryID) | .[0].address // empty')

if [[ -n "$ADDR" ]]; then
    hyprctl dispatch focuswindow "address:$ADDR"
    exit 0
fi

"$@" &
disown
