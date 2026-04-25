#!/usr/bin/env fish
# Capture the screenshots referenced by README.md.
#
# Usage: scripts/capture-readme-screenshots.fish [name...]
#   name = desktop | bar | terminal | neovim | rofi | notifications | lock
#   no args = run them all in order, with prompts between each
#
# Output goes to assets/screenshots/<name>.png (overwrites).
#
# Each step prints what to set up, waits for you to press enter, and
# then captures. For region shots (bar, terminal, neovim, rofi,
# notifications) you'll be asked to drag a selection with slurp.

set -l root (git rev-parse --show-toplevel 2>/dev/null; or pwd)
set -l out "$root/assets/screenshots"
mkdir -p "$out"

function _grab_full
    grim "$out/$argv[1].png"
    echo "  saved $out/$argv[1].png"
end

function _grab_region
    set -l geometry (slurp)
    if test -z "$geometry"
        echo "  cancelled"
        return 1
    end
    grim -g "$geometry" "$out/$argv[1].png"
    echo "  saved $out/$argv[1].png"
end

function _focus_window
    set -l class $argv[1]
    set -l addr (hyprctl clients -j | jq -r --arg c "$class" '.[] | select(.class == $c) | .address' | head -n1)
    if test -n "$addr"
        hyprctl dispatch focuswindow address:$addr >/dev/null
        sleep 0.3
    end
end

function _step
    set -l name $argv[1]
    set -l hint $argv[2..-1]
    echo
    echo "=== $name ==="
    echo $hint
    read -P "press enter when ready (or s to skip): " ans
    if test "$ans" = s
        return 1
    end
    return 0
end

function shot_desktop
    if _step desktop "Compose a clean desktop. Show your wallpaper, the bar, maybe a focused window or two. Hit enter to capture the full output."
        _grab_full desktop
    end
end

function shot_bar
    if _step bar "Make the bar visible. Drag a region across just the bar (top of screen)."
        _grab_region bar
    end
end

function shot_terminal
    if _step terminal "Open a Ghostty window with something interesting on screen (eza --tree, btop, neofetch, your prompt). Drag a region around the terminal."
        _focus_window com.mitchellh.ghostty
        _grab_region terminal
    end
end

function shot_neovim
    if _step neovim "Open Neovim on a file with syntax color, completion, or telescope visible. Drag a region around the editor window."
        _focus_window com.mitchellh.ghostty
        _grab_region neovim
    end
end

function shot_rofi
    if _step rofi "Launch rofi (super+space or whatever your bind is). Drag a region around the launcher."
        _grab_region rofi
    end
end

function shot_notifications
    if _step notifications "Trigger a notification (e.g. notify-send 'Hello' 'Sample notification'). Drag a region around the toast."
        _grab_region notifications
    end
end

function shot_lock
    if _step lock "Lock the screen with hyprlock. After unlocking, this script will capture from a screenshot you take during the lock with grimblast or hyprctl. Easier path: just take it manually with grim while a second device runs grim, OR set HYPRLOCK_SCREENSHOT_CMD ahead of time."
        echo "  not automated; capture lock.png manually."
        return
    end
end

set -l requested $argv
if test (count $requested) -eq 0
    set requested desktop bar terminal neovim rofi notifications lock
end

for name in $requested
    switch $name
        case desktop;       shot_desktop
        case bar;           shot_bar
        case terminal;      shot_terminal
        case neovim;        shot_neovim
        case rofi;          shot_rofi
        case notifications; shot_notifications
        case lock;          shot_lock
        case '*';           echo "unknown: $name"
    end
end

echo
echo "done. assets/screenshots/:"
ls -la "$out"
