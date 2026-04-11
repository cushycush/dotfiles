# AGENTS.md - Dotfiles Repository

## Repository Overview

Personal dotfiles for a Linux (Hyprland) desktop environment. Primary component is a
NeoVim configuration using lazy.nvim as the plugin manager. Other configs: Ghostty
(terminal), Hyprland (compositor), Tmux, Fish shell, KMonad, Waybar, Rofi, Quickshell,
Nushell.

## Repository Structure

```
dotfiles/
├── NeoVim/              # Main NeoVim config (symlinked to ~/.config/nvim)
│   ├── init.lua          # Entry point - just requires config.lazy
│   ├── lua/
│   │   ├── config/       # Core NeoVim settings
│   │   │   ├── lazy.lua      # lazy.nvim bootstrap + plugin loader
│   │   │   ├── options.lua   # vim.opt settings
│   │   │   ├── globals.lua   # vim.g settings (leader = space)
│   │   │   ├── keymaps.lua   # Global keybindings
│   │   │   ├── autocmds.lua  # Autocommands
│   │   │   ├── highlights.lua # Custom highlight overrides
│   │   │   └── lsp/
│   │   │       ├── tools.lua      # Central LSP/formatter/linter registry
│   │   │       └── diagnostics.lua # Diagnostic display config
│   │   ├── plugins/      # One file per plugin (lazy.nvim spec format)
│   │   │   └── themes/   # Theme plugin specs
│   │   └── utils/        # Shared utility modules
│   │       ├── neovim.lua    # Buffer/window/highlight helpers
│   │       └── chars.lua     # Unicode chars, border styles, icons
│   └── native/           # Non-plugin NeoVim modules
│       ├── lsp.lua        # Diagnostic navigation, format-on-save
│       └── themes/
├── Ghostty/             # Ghostty terminal config
├── Hyprland/            # Hyprland compositor config
├── Tmux/                # Tmux config
├── Shells/Fish/         # Fish shell config
├── KMonad/              # Keyboard remapping
├── Waybar/              # Status bar
├── Rofi/                # App launcher
├── Quickshell/          # Shell widgets
└── Nushell/             # Nushell config
```

## Build / Lint / Test Commands

This is a dotfiles repo - there is no build system, test suite, or CI.

### Lua Linting

```bash
# luacheck is configured via NeoVim/.luacheckrc
luacheck NeoVim/lua/

# lua-language-server uses NeoVim/.luarc.json
# Globals: vim (diagnostic), use (read_globals in luacheck)
# Runtime: LuaJIT
```

### Formatters & Linters (managed by Mason + guard.nvim)

All tooling is centrally registered in `NeoVim/lua/config/lsp/tools.lua`:
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

- **Files**: lowercase with hyphens for plugin specs (e.g., `blink-cmp.lua`,
  `trouble-nvim.lua`), lowercase with underscores for config modules
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

- **Ghostty**: Plain text config file + GLSL shaders in `shaders/`
- **Hyprland**: `.conf` files with module includes in `modules/`
- **Tmux**: Standard `tmux.conf`
- No special tooling required for these - they are plain config files.

### Things to Avoid

- Do NOT use Vimscript - everything is Lua
- Do NOT add `vim` to requires - it's a global (declared in `.luarc.json` and `.luacheckrc`)
- Do NOT duplicate tool registrations - use `config/lsp/tools.lua` as the single source
- Do NOT use `config` function in plugin specs when `opts` table suffices
- Do NOT hardcode border characters - use `utils/chars.lua`
