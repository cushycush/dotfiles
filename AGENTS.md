# AGENTS.md - Dotfiles Repository

## Repository Overview

Personal dotfiles for a Linux (Hyprland) desktop environment. Symlinks under
`~/.config/` are managed by [`store`](https://github.com/cushycush/store);
package install state is managed by its companion `stock`. Both read from
`.store/` at the repo root.

Naming convention: kebab-case for everything authored here. Upstream
directories (e.g. `quickshell/HyprQuickFrame/`) keep their original case.

## Repository Structure

```
dotfiles/
├── desktop/            # Wayland desktop UX
│   ├── hyprland/       # compositor + lock screen + module includes
│   ├── quickshell/     # shell widgets (HyprQuickFrame submodule kept upstream-named)
│   ├── rofi/           # launcher
│   └── waybar/         # bar
├── editors/
│   └── neovim/         # see "NeoVim layout" below
├── fonts/
│   └── fontconfig/     # font fallback rules
├── shells/
│   ├── fish/           # primary shell config + fisher-managed plugins
│   └── nushell/
├── terminals/
│   ├── ghostty/        # terminal + GLSL shaders + themes
│   └── tmux/           # tmux.conf + TPM-managed plugins
├── tools/              # CLI / TUI tool configs
│   ├── gh/             # config.yml only; hosts.yml stays out (auth token)
│   ├── glow/
│   ├── htop/
│   ├── lazygit/
│   └── mise/
├── kmonad/             # keyboard remapping daemon (no peer; lives at top level)
└── .store/
    ├── config.yaml     # store: name -> ~/.config target mapping
    ├── packages.yaml   # stock: install groups (base, desktop, dev, ...)
    └── secrets.enc     # store-encrypted env secrets (created on first secret set)
```

### NeoVim layout (`editors/neovim/`)

```
editors/neovim/
├── init.lua            # entry point - requires config.lazy
├── lua/
│   ├── config/         # core settings
│   │   ├── lazy.lua    # lazy.nvim bootstrap + plugin loader
│   │   ├── options.lua # vim.opt settings
│   │   ├── globals.lua # vim.g (leader = space)
│   │   ├── keymaps.lua # global bindings
│   │   ├── autocmds.lua
│   │   ├── highlights.lua
│   │   └── lsp/
│   │       ├── tools.lua        # central LSP/formatter/linter registry
│   │       └── diagnostics.lua  # diagnostic display
│   ├── plugins/        # one file per plugin (lazy.nvim spec)
│   │   └── themes/
│   └── utils/
│       ├── neovim.lua  # buffer/window helpers
│       └── chars.lua   # unicode chars, borders, icons
└── native/             # non-plugin modules
    ├── lsp.lua         # diagnostic nav, format-on-save
    └── themes/
```

## store and stock

```bash
store status              # show all symlinks and their state
store apply               # reconcile ~/.config symlinks from .store/config.yaml
store rename <old> <new>  # rename a store, re-link all targets
store adopt <path>        # move ~/.config/<x> into the repo and symlink it back
store secret set <NAME>   # set an encrypted env-secret (interactive passphrase)

stock doctor              # check declared vs installed
stock diff                # preview install changes
stock install [group...]  # install missing packages from a group
```

`stock` groups live in `.store/packages.yaml`: `base`, `network`, `bluetooth`,
`audio`, `gpu`, `desktop`, `fonts`, `terminals`, `dev`, `apps`, `printing`,
`flatpak`. Each runs whichever package manager is available (`pacman` here).

## Secrets

Encrypted env vars live in `.store/secrets.enc`. To populate:

```bash
store secret set ANTHROPIC_API_KEY   # repeat for each name below
```

Tracked names:
`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GITHUB_TOKEN`, `NPM_TOKEN`, `VERCEL_TOKEN`.

To export them into a fish shell, run `load-secrets`. The function prompts once
for the store passphrase and exports whichever of the named secrets are set.
It is not auto-loaded; interactive shells would otherwise prompt on every
startup.

## Known limitations

`store apply` walks every file in each store and renders it as a Go template
before it stages symlinks. Two files in this repo contain literal `{{ ... }}`
that breaks the renderer:

- `shells/fish/conf.d/abbr_tips.fish`: the fish-abbreviation-tips plugin uses
  `{{ .abbr }}` and `{{ .cmd }}` as its own placeholders.

Workaround: existing dir-level symlinks survive the render error, so things
keep working. To rename `shells/fish` itself, do it manually (`git mv` plus
`ln -sfn`) instead of `store rename` so the symlink updates atomically.

Upstream `vim-tmux-navigator/.github/` was removed for the same reason.

## Build / Lint / Test Commands

This is a dotfiles repo - there is no build system, test suite, or CI.

### Lua Linting

```bash
# luacheck is configured via editors/neovim/.luacheckrc
luacheck editors/neovim/lua/

# lua-language-server uses editors/neovim/.luarc.json
# Globals: vim (diagnostic), use (read_globals in luacheck)
# Runtime: LuaJIT
```

### Formatters & Linters (managed by Mason + guard.nvim)

All tooling is centrally registered in `editors/neovim/lua/config/lsp/tools.lua`:
- **Lua**: stylua (formatter)
- **JS/TS/CSS/HTML/Markdown/Svelte/Vue**: prettierd (formatter), eslint_d (linter)
- **Python**: black (formatter), flake8 (linter)
- **Go**: gofumpt (formatter)
- **C/C++**: clang-format (formatter), cpplint (linter)
- **Shell**: shfmt (formatter), shellcheck (linter)
- **JSON**: fixjson→jq (formatter), eslint_d (linter)
- **Dockerfile**: prettierd (formatter), hadolint (linter)

Format-on-save is enabled via guard.nvim (`fmt_on_save = true`).

### Validating Changes

```bash
# Quick smoke test - open NeoVim and check for errors
nvim --headless "+Lazy! sync" +qa
# Or just open nvim and check :messages, :checkhealth
```

## Code Style Guidelines

### Language: Lua (LuaJIT)

All NeoVim config is Lua targeting LuaJIT (Lua 5.1 + FFI). No Vimscript.

### Indentation & Formatting

- **Tabs for indentation** (rendered as 2-space width in the editor, but files use real tabs)
- stylua is the authoritative formatter for Lua files
- Line length: soft limit at 100 columns (`colorcolumn = "100"`)
- No trailing whitespace (stripped on format)

### Module Pattern

Every utility/native module follows the `local M = {} ... return M` pattern:

```lua
local M = {}

function M.some_function()
    -- implementation
end

return M
```

### Plugin Specs (lazy.nvim)

Each plugin gets its own file in `lua/plugins/`. The file returns a lazy.nvim spec table:

```lua
return {
    "author/plugin-name",
    event = "VeryLazy",  -- or ft, cmd, keys for lazy loading
    dependencies = { ... },
    opts = { ... },      -- preferred over config when possible
    config = function()
        -- only when opts isn't sufficient
    end,
}
```

- One plugin per file. Filename matches the plugin name (e.g., `snacks.lua`).
- Use `opts` table when the plugin supports `setup(opts)`. Use `config` function only
  when procedural setup is needed.
- Lazy-load aggressively via `event`, `ft`, `cmd`, or `keys`.

### File Headers

Config files use a banner comment style:

```lua
-- ================================================================================================
-- TITLE : Module Name
-- ABOUT : brief description
-- ================================================================================================
```

Not all files use this - it's optional. Utility modules and plugin specs typically skip it.

### Imports / Requires

- Use `local X = require("module.path")` at the top of the file
- Common aliases: `local U = require("utils.neovim")`, `local C = require("utils.chars")`
- Require paths are relative to `lua/` directory

### Naming Conventions

- **Files**: lowercase with hyphens (`blink-cmp.lua`, `trouble-nvim.lua`).
  Single-word config modules stay single-word (`autocmds.lua`, `options.lua`).
- **Variables/functions**: `snake_case`
- **Module tables**: single uppercase letter (`M`, `U`, `C`) or descriptive lowercase
- **Autocmd groups**: `PascalCase` strings (e.g., `"UserConfig"`, `"ts_ls_dedupe"`)
- **Keymaps**: always include `desc` field for which-key integration

### Error Handling

- Use `pcall` for operations that may fail (LSP format, plugin loads)
- Pattern: `local status, _ = pcall(fn)` then handle failure
- guard.nvim uses `pcall` wrappers (`safe_fmt`, `safe_lint`) for formatter registration

### Central Tool Registry

`lua/config/lsp/tools.lua` is the single source of truth for:
- LSP servers (`M.servers`)
- Formatters (`M.formatters`) - keyed by filetype
- Linters (`M.linters`) - keyed by filetype

When adding language support, update this file. Mason, guard.nvim, and lspconfig all
read from it.

### Highlight Customizations

Custom highlight overrides go in `lua/config/highlights.lua`. Uses a color palette
table and applies via `ColorScheme` autocmd. Current theme: oxocarbon.

### Key Conventions

- Leader key: `<Space>`
- `<leader>f*` - find/search (files, grep, buffers, keymaps)
- `<leader>g*` - git operations (lazygit, branches, log, status, diff)
- `<leader>s*` - LSP symbols
- `g*` - goto (definition, references, implementation, type def)
- `[d` / `]d` - diagnostic navigation
- `<leader>e` - file explorer (snacks.nvim)
- `<leader>bd` - delete buffer

### Border & Icon System

`utils/chars.lua` provides a centralized border/icon system. Use
`C.get_border_chars(desc)` which returns theme-aware borders. Available descriptors:
`"telescope"`, `"completion"`, `"cmdline"`, `"search"`, `"float"`, `"lsp"`.

### Non-NeoVim Configs

- **terminals/ghostty**: plain text config + GLSL shaders in `shaders/`
- **desktop/hyprland**: `.conf` files with module includes in `modules/`
- **terminals/tmux**: `tmux.conf` plus TPM-managed plugins under `plugins/`
- **shells/fish**: `config.fish`, fisher-managed plugins in `conf.d/` and
  `functions/`. Custom helpers (e.g. `load-secrets`) go under `functions/`.
- No special tooling required for these; they are plain config files.

### Things to Avoid

- Do NOT use Vimscript - everything is Lua
- Do NOT add `vim` to requires - it's a global (declared in `.luarc.json` and `.luacheckrc`)
- Do NOT duplicate tool registrations - use `config/lsp/tools.lua` as the single source
- Do NOT use `config` function in plugin specs when `opts` table suffices
- Do NOT hardcode border characters - use `utils/chars.lua`
