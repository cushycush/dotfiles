#!/usr/bin/sh
# Capture the focused monitor (or $1 if passed) into the README's lock.png.
# Wired up as a bindl in desktop/hyprland/modules/keybinds.conf so it can
# fire while hyprlock has the keyboard grab.

set -eu

out="${1:-$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')}"
dest="$HOME/dotfiles/assets/screenshots/lock.png"
log="/tmp/lock-ss.log"

{
    echo "=== $(date) ==="
    echo "monitor=$out"
    grim -o "$out" "$dest"
    echo "saved $dest ($(stat -c%s "$dest" 2>/dev/null) bytes)"
} >> "$log" 2>&1
