#!/usr/bin/env bash
# Turn the laptop panel off while the lid is closed and an external display is
# connected (logind ignores the lid when docked), and back on otherwise.
set -euo pipefail

# Keep in sync with the eDP-1 monitor line in hyprland.conf.
EDP_RULE="eDP-1, 3840x2400@120, auto-down, 2"

external=false
for status in /sys/class/drm/card*-*/status; do
    [[ "$status" == *eDP* ]] && continue
    [[ "$(cat "$status")" == connected ]] && external=true
done

if grep -q closed /proc/acpi/button/lid/*/state && $external; then
    hyprctl keyword monitor "eDP-1, disable"
else
    hyprctl keyword monitor "$EDP_RULE"
    # Hyprland can report eDP-1 as on while its modeset failed (seen when the
    # lid opened during an external display hotplug), leaving the panel blank
    # until it is toggled. Retry until the kernel agrees it is enabled.
    for _ in 1 2 3 4 5; do
        sleep 1
        [[ "$(cat /sys/class/drm/card*-eDP-1/enabled)" == enabled ]] && break
        hyprctl keyword monitor "eDP-1, disable"
        hyprctl keyword monitor "$EDP_RULE"
    done
fi
