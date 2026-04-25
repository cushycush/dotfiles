function derust-monitor --description "Display a white screen fullscreen on a monitor to clear NanoIPS image retention"
    set -l img ~/dotfiles/assets/white-5120x2160.png
    set -l monitor DP-3
    set -l duration 1800   # 30 min default

    # usage: derust-monitor [monitor] [duration_seconds]
    if test (count $argv) -ge 1
        set monitor $argv[1]
    end
    if test (count $argv) -ge 2
        set duration $argv[2]
    end

    if not test -f $img
        echo "derust-monitor: missing $img" >&2
        return 1
    end
    if not type -q mpv
        echo "derust-monitor: mpv not installed (it's in stock's dev group)" >&2
        return 1
    end

    set -l mins (math --scale=1 $duration / 60)
    echo "derust-monitor: white on $monitor for $mins min. Press q in mpv to stop early."

    mpv \
        --image-display-duration=inf \
        --idle=once \
        --keep-open=yes \
        --no-osc \
        --no-osd-bar \
        --no-cursor-autohide \
        --fullscreen \
        $img &
    set -l pid $last_pid

    sleep 0.5
    hyprctl dispatch focuswindow pid:$pid >/dev/null 2>&1
    hyprctl dispatch movewindow mon:$monitor >/dev/null 2>&1

    # poll until duration elapses or mpv exits early
    set -l end (math (date +%s) + $duration)
    while kill -0 $pid 2>/dev/null
        if test (date +%s) -ge $end
            kill $pid 2>/dev/null
            break
        end
        sleep 5
    end
    wait $pid 2>/dev/null
    echo "derust-monitor: done"
end
