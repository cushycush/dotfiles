if status is-interactive
  fish_vi_key_bindings
  /usr/sbin/mise activate fish | source
  zoxide init fish | source
end

set -g fish_greeting
set -u EDITOR nvim
set -u VISUAL nvim
set -u SUDO_EDITOR nvim

alias ls='eza --icons --group-directories-first'
alias cat='bat'
alias grep='rg'
alias cd='z'
alias n='nvim'

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
