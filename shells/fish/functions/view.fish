function view --description "Open image(s) in imv until you close them (q to quit, f to fullscreen)"
    if test (count $argv) -eq 0
        echo "usage: view <file>..." >&2
        return 1
    end

    if type -q imv
        imv $argv
    else if type -q mpv
        mpv --image-display-duration=inf --keep-open=yes --no-osc $argv
    else
        echo "view: needs imv or mpv installed" >&2
        return 1
    end
end
