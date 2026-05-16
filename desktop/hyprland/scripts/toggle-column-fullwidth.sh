#!/usr/bin/env bash
# Toggle the focused column between full viewport width (1.0) and the default
# column_width (0.5). Bound to SUPER+F. Heuristic: if the focused window is
# already taking >=95% of the monitor's usable logical width, shrink it to
# 0.5; otherwise expand to 1.0.

set -e

active=$(hyprctl activewindow -j 2>/dev/null) || exit 0
win_w=$(printf '%s' "$active" | jq -r '.size[0] // 0')
mon_id=$(printf '%s' "$active" | jq -r '.monitor // -1')

# No active window? Bail.
if [ -z "$mon_id" ] || [ "$mon_id" = "-1" ] || [ "$win_w" = "0" ]; then
    exit 0
fi

mon_line=$(hyprctl monitors -j 2>/dev/null \
    | jq -r --argjson id "$mon_id" '.[] | select(.id == $id) | "\(.width) \(.scale) \(.reserved[0]) \(.reserved[2])"')

if [ -z "$mon_line" ]; then
    exit 0
fi

read -r mw scale res_l res_r <<<"$mon_line"

# Logical monitor width minus left/right reserved zones (bars/exclusive layers).
logical_w=$(awk -v w="$mw" -v s="$scale" -v l="$res_l" -v r="$res_r" \
    'BEGIN { print int(w/s - l - r) }')
threshold=$(awk -v lw="$logical_w" 'BEGIN { print int(lw * 0.95) }')

if [ "$win_w" -ge "$threshold" ]; then
    hyprctl dispatch 'hl.dsp.layout("colresize 0.5")'
else
    hyprctl dispatch 'hl.dsp.layout("colresize 1.0")'
fi
