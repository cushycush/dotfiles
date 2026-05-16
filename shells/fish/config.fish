if status is-interactive
  fish_vi_key_bindings
  bind -M insert  \ev fish_clipboard_paste
  bind -M default \ev fish_clipboard_paste
  /usr/sbin/mise activate fish | source
  zoxide init fish | source
end

set -g fish_greeting
set -u EDITOR nvim
set -u VISUAL nvim
set -u SUDO_EDITOR nvim

alias ls='eza --icons --group-directories-first'
# cat is a function in functions/cat.fish — routes images through kitten icat,
# everything else through bat.
alias grep='rg'
alias cd='z'
alias n='nvim'

# abbreviations
abbr -a god 'godot --fullscreen'

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
