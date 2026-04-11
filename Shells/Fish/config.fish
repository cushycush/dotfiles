if status is-interactive
  fish_vi_key_bindings
  /usr/sbin/mise activate fish | source
  zoxide init fish | source
end

set -g fish_greeting

alias ls='eza --icons --group-directories-first'
alias cat='bat'
alias grep='rg'
alias cd='z'
alias n='nvim'
