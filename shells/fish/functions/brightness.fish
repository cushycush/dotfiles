function brightness --description "Get or set monitor brightness via ddcutil (VCP 0x10)"
    set -l value ""
    set -l target ""

    if test (count $argv) -ge 1
        set value $argv[1]
    end
    if test (count $argv) -ge 2
        set target $argv[2]
    end

    # Build "display#:wayland-name" pairs from `ddcutil detect --terse`
    set -l detect (ddcutil detect --terse 2>/dev/null)
    set -l pairs
    set -l current_display ""
    for line in $detect
        if string match -rq '^Display (\d+)$' -- $line
            set current_display (string match -r 'Display (\d+)' -- $line)[2]
        else if string match -rq 'DRM connector:\s+card\d+-' -- $line
            set -l name (string replace -r '.*card\d+-' '' -- $line | string trim)
            if test -n "$current_display"
                set -a pairs "$current_display:$name"
            end
            set current_display ""
        end
    end

    if test (count $pairs) -eq 0
        echo "brightness: no DDC-capable displays detected" >&2
        return 1
    end

    for pair in $pairs
        set -l d (string split ':' $pair)[1]
        set -l name (string split ':' $pair)[2]

        if test -z "$value"
            # query mode
            set -l line (ddcutil --display $d getvcp 10 2>/dev/null)
            set -l cur (string match -r 'current value =\s+(\d+)' -- $line)[2]
            set -l max (string match -r 'max value =\s+(\d+)' -- $line)[2]
            printf "  %-12s %3s / %3s\n" $name $cur $max
            continue
        end

        if test -n "$target"; and test "$target" != "$name"
            continue
        end

        ddcutil --display $d --noverify setvcp 10 $value >/dev/null 2>&1
        if test $status -eq 0
            printf "  %-12s -> %s\n" $name $value
        else
            printf "  %-12s FAILED\n" $name
        end
    end
end
