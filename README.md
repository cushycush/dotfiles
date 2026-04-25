# dotfiles

A Hyprland desktop on Arch, themed in Nord, with the configs grouped
by purpose and the symlinks managed by [`store`](https://github.com/cushycush/store)
+ [`stock`](https://github.com/cushycush/stock).

![hero](assets/screenshots/desktop.png)

## What you're looking at

```
compositor    Hyprland
status bar    Quickshell  (custom QML, see desktop/quickshell/)
launcher      Rofi
notifications swaync + Quickshell toasts
lock screen   hyprlock     (Nord palette, matches the bar)
shell         Fish + Pure prompt
multiplexer   tmux         (vim-tmux-navigator, tmux-yank)
terminal      Ghostty      (MonoLisa Nerd Font, custom GLSL shaders)
editor        Neovim       (lazy.nvim, nordic.nvim, blink.cmp)
font          MonoLisa Nerd + Phosphor icons
palette       Nord         (#242933 base, nord13 yellow accents)
wallpaper     awww
```

## Tour

| Bar | Terminal |
| --- | --- |
| ![bar](assets/screenshots/bar.png) | ![ghostty](assets/screenshots/terminal.png) |

| Neovim | Launcher |
| --- | --- |
| ![neovim](assets/screenshots/neovim.png) | ![rofi](assets/screenshots/rofi.png) |

| Notifications | Lock |
| --- | --- |
| ![swaync](assets/screenshots/notifications.png) | ![hyprlock](assets/screenshots/lock.png) |

## Layout

```
dotfiles/
├── desktop/         hyprland · quickshell · rofi · waybar
├── editors/         neovim
├── fonts/           fontconfig
├── shells/          fish · nushell
├── terminals/       ghostty · tmux
├── tools/           gh · glow · htop · lazygit · mise
├── kmonad/
└── .store/          config.yaml · packages.yaml · secrets.enc
```

Top-level groups are kebab-case. Upstream-vendored directories
(`quickshell/HyprQuickFrame/`) keep their original names.

## How the dotfiles get installed

Two tools do all the work, both reading from `.store/` at the repo root.

### `store`: symlinks

`.store/config.yaml` maps each store directory to its target under
`~/.config`. One command reconciles everything:

```bash
store apply              # create / repair every symlink
store status             # show what's linked, what's broken
store rename <old> <new> # move a store and re-link in one step
store adopt ~/.config/x  # move an existing config into the repo
```

Renames are atomic: `store rename hyprland desktop/hyprland` moves the
directory on disk, edits the config, and re-points the symlink under
`~/.config/hypr` to the new path without ever leaving it dangling.

For sensitive env vars, store keeps an encrypted blob at
`.store/secrets.enc`:

```bash
store secret set ANTHROPIC_API_KEY      # prompts for value + passphrase
store secret list                       # list names (after passphrase)
```

A fish helper exports them into the current shell:

```fish
load-secrets
# store passphrase: ************
# load-secrets: exported 5 of 5 secrets
```

The function reads the passphrase once, calls `store secret get` for each
name with `STORE_PASSPHRASE` set inline, and forgets the passphrase when
it returns. Tracked names: `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`,
`GITHUB_TOKEN`, `NPM_TOKEN`, `VERCEL_TOKEN`.

### `stock`: packages

`.store/packages.yaml` is grouped by purpose, not by package manager:

```yaml
packages:
  base:        # kernel, init, package managers, devtools shared by every install
  network:     # NetworkManager + iwd
  bluetooth:   # bluez stack
  audio:       # pipewire + pavucontrol + easyeffects
  gpu:         # nvidia drivers
  desktop:     # Hyprland + wayland tooling + theming engine
  fonts:       # noto, ttf families, font managers
  terminals:   # ghostty, kitty, tmux, fish, kmonad
  dev:         # editors, git, language tooling, CLI utilities
  apps:        # firefox, tesseract, scanning utilities
  printing:    # cups stack
  flatpak:     # flatpak runtime + companions
```

Each group can declare packages for any supported manager (`pacman`,
`brew`, `apt`, `npm`, `go`, `cargo`, `pipx`, `gem`); stock runs whichever
is available on the host.

```bash
stock install               # install everything missing
stock install desktop dev   # install just two groups
stock diff                  # preview without changing anything
stock doctor                # confirm declared == installed
stock snapshot              # write currently installed packages back to packages.yaml
```

## Bootstrapping a fresh machine

```bash
# 1. install the two tools
yay -S store stock-bin

# 2. clone
git clone https://github.com/cushycush/dotfiles ~/dotfiles
cd ~/dotfiles

# 3. install every package group
stock install

# 4. link every config into ~/.config
store apply

# 5. (optional) populate secrets
store secret set ANTHROPIC_API_KEY
store secret set OPENAI_API_KEY
# ...
```

`stock bootstrap` chains hooks + install + store-apply if you want it in
one shot.

## Highlights

- **Quickshell bar.** Hand-written QML, see `desktop/quickshell/bar/`.
  Live GitHub PR + issue counts via the `gh` CLI, Bluetooth toggle that
  speaks to bluez over D-Bus, system settings panel for wifi / sound /
  bluetooth in one place.
- **Quickshell notifications.** Custom toast surface; only mapped while
  toasts are visible so it never steals input from windows beneath.
- **hyprlock.** Reskinned to match the bar palette (Nord polar night
  base, snow text, aurora yellow accents).
- **Neovim.** lazy.nvim plugin manager. Single tool registry in
  `editors/neovim/lua/config/lsp/tools.lua` (Mason, guard.nvim, and
  lspconfig all read from the same table). Nordic theme, oxocarbon
  fallback. blink.cmp for completion, snacks.nvim for the file picker
  and dashboard.
- **Ghostty.** MonoLisa Nerd Font with most stylistic sets enabled.
  Custom GLSL shaders under `terminals/ghostty/shaders/`. Default command
  attaches to a shared tmux session so every new window joins the same
  workspace.
- **Tmux.** vim-tmux-navigator wired to Hyprland keybinds, so the same
  `Ctrl-h/j/k/l` jumps between Hyprland windows, tmux panes, and Neovim
  splits without thinking about which is which.

## License

MIT. Take what's useful.
