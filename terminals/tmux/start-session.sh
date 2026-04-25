#!/usr/bin/env bash
# Start a fresh tmux session with three named windows: shell, agent, git.
# Each new terminal gets its own independent session (named main-<pid>),
# so windows in one terminal don't switch windows in another.

SESSION="main-$$"

tmux new-session -d -s "$SESSION" -n "shell"
tmux new-window  -t "$SESSION"   -n "agent"
tmux new-window  -t "$SESSION"   -n "git"
tmux select-window -t "$SESSION:1"

exec tmux attach-session -t "$SESSION"
