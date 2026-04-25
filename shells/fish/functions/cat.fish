function cat --description "cat that renders image files via kitten icat, otherwise bat"
    # Pipe / redirect / non-tty -> real cat (bat would auto-detect, but be explicit)
    if not isatty stdout
        command cat $argv
        return
    end

    # Single existing file with image mime -> kitten icat
    if test (count $argv) -eq 1; and not string match -q -- '-*' $argv[1]
        set -l f $argv[1]
        if test -f $f; and type -q kitten
            set -l mime (file --brief --mime-type -- $f 2>/dev/null)
            if string match -q 'image/*' -- $mime
                if set -q TMUX
                    kitten icat --passthrough=tmux -- $f
                else
                    kitten icat -- $f
                end
                return
            end
        end
    end

    # Default: bat (the user's original `alias cat=bat`)
    bat $argv
end
