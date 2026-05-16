function fish_clipboard_paste
    set -l data
    if type -q wl-paste
        set data (wl-paste 2>/dev/null | string collect)
    else if type -q xclip
        set data (xclip -selection clipboard -o 2>/dev/null | string collect)
    end

    test -n "$data"; or return

    # Heredocs and explicit shell scripts get pasted verbatim so multi-line
    # structure survives.
    if string match -qr '<<-?\s*[A-Za-z_]' -- $data
        commandline -i -- $data
        return
    end

    # Collapse shell line continuations and any wrap-induced newlines so a
    # command that spans visual lines lands on one logical line.
    # Each step passes the data positionally (not via pipe), because
    # `string replace` reads piped stdin line-by-line, which would strip
    # newlines out before the next regex ever sees them.
    set -l cleaned $data
    set cleaned (string replace -ra '\\\\\s*\n\s*' ' ' -- $cleaned | string collect)
    set cleaned (string replace -ra '\n' ' ' -- $cleaned | string collect)
    set cleaned (string replace -ra '\s+' ' ' -- $cleaned | string collect)
    set cleaned (string trim -- $cleaned)
    commandline -i -- $cleaned
end
