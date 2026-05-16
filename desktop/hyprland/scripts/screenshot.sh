#!/usr/bin/env bash
# Screenshot via grim. First arg is the mode, second arg is the destination:
#   region   slurp-select a rectangle
#   output   the currently-focused monitor
#   window   the active Hyprland window
#
#   clipboard  pipe PNG to wl-copy (default)
#   file       save PNG to ~/media/screenshots/screenshot-<timestamp>.png

set -e

mode=${1:-region}
dest=${2:-clipboard}

case "$mode" in
    region)
        geom=$(slurp) || exit 0
        target=(-g "$geom")
        ;;
    output)
        out=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
        [ -n "$out" ] || exit 1
        target=(-o "$out")
        ;;
    window)
        geom=$(hyprctl activewindow -j \
            | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        [ "$geom" != "null,null nullxnull" ] || exit 0
        target=(-g "$geom")
        ;;
    *)
        echo "usage: screenshot.sh {region|output|window} [clipboard|file]" >&2
        exit 2
        ;;
esac

case "$dest" in
    clipboard)
        tmp=/tmp/screenshot-clipboard.png
        grim "${target[@]}" "$tmp"
        wl-copy --type image/png < "$tmp"
        notify-send -a screenshot -i "$tmp" "Screenshot copied" "Saved to clipboard"
        ;;
    file)
        dir=$HOME/media/screenshots
        mkdir -p "$dir"
        path=$dir/screenshot-$(date +%Y-%m-%d-%H%M%S).png
        grim "${target[@]}" "$path"
        notify-send -a screenshot -i "$path" "Screenshot saved" "$path"
        ;;
    *)
        echo "usage: screenshot.sh {region|output|window} [clipboard|file]" >&2
        exit 2
        ;;
esac
