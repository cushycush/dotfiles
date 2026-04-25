function cat --description "cat that renders image files inline via kitten icat"
    # Non-interactive (pipe, redirect, script) -> real cat
    if not isatty stdout
        command cat $argv
        return
    end

    # No args -> real cat (reads stdin)
    if test (count $argv) -eq 0
        command cat
        return
    end

    # Any flag or stdin marker, or multiple files -> real cat
    if test (count $argv) -gt 1
        command cat $argv
        return
    end
    if string match -q -- '-*' $argv[1]
        command cat $argv
        return
    end

    # Single path: image-render if mime says so AND kitten is available
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

    command cat $argv
end
