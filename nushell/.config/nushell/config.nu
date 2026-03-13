# config.nu
#
# Installed by:
# version = "0.110.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R
kmonad ~/.config/kmonad/config.kbd

$env.PROMPT_COMMAND = { ||
  starship prompt --cmd-duration $env.CMD_DURATION_MS
}
$env.PROMPT_INDICATOR = ""
$env.PROMPT_MULTILINE_INDICATOR = "::: "
$env.PROMPT_COMMAND_RIGHT = { || starship prompt --right }
