#!/usr/bin/env bash
# Attach to a shared tmux session, or create it on first run with three
# named windows: shell, agent, git.

SESSION="main"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux new-session -d -s "$SESSION" -n "shell"
    tmux new-window  -t "$SESSION"   -n "agent"
    tmux new-window  -t "$SESSION"   -n "git"
    tmux select-window -t "$SESSION:1"
fi

# Mirrored clients — every terminal views the same session state.
# Switching windows in one terminal switches them in all others.
exec tmux attach-session -t "$SESSION"

# Independent clients — each terminal gets its own view into the session,
# so you can browse different windows in each one without mirroring.
# Swap the line above for this line to enable:
# exec tmux new-session -t "$SESSION"
