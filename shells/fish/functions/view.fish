function view --description "Open image(s) in mpv until you close them (q to quit, f to fullscreen)"
    if test (count $argv) -eq 0
        echo "usage: view <file>..." >&2
        return 1
    end
    if not type -q mpv
        echo "view: mpv not installed" >&2
        return 1
    end

    mpv \
        --image-display-duration=inf \
        --idle=once \
        --keep-open=yes \
        --no-osc \
        --no-osd-bar \
        $argv
end
