# AGENTS.md - Neovim/Dotfiles Development Guide

## Overview

This repository contains dotfiles including Neovim configuration (Lua), Ghostty terminal config, Nushell shell config, and Tmux configuration.

**Main focus: Neovim Lua configuration** - The primary codebase is in `nvim/.config/nvim/`.

## Build/Lint/Test Commands

### Lua Linting
```bash
# Run luacheck on all Lua files
luacheck lua/

# Run luacheck on a specific file
luacheck lua/config/options.lua

# With the .luacheckrc configuration
luacheck --config .luacheckrc lua/
```

### Lua Formatting
```bash
# Format Lua files with stylua (if installed)
stylua lua/

# Format specific file
stylua lua/plugins/snacks.lua

# Check formatting without modifying
stylua --check lua/
```

### Neovim Config Validation
```bash
# Check Neovim config loads without errors
nvim --headless -c 'quit' 2>&1

# Test specific config file
nvim --headless -c 'lua require("config.lsp.tools")' -c 'quit'
```

### Shell Scripts (tmux-yank)
```bash
# Lint shell scripts
shellcheck scripts/*.sh

# Run plugin tests (TPM)
./tests/test_plugin_installation.sh
```

## Code Style Guidelines

### Lua Conventions

#### Indentation & Formatting
- Use **2 spaces** for indentation (no tabs)
- Always use `vim.opt` over `vim.o`/`vim.go` for options
- Use `vim.keymap.set()` with `desc` option for all keymaps
- Use `vim.api.nvim_create_autocmd()` with `desc` for autocommands
- End files with a single newline

#### File Structure
```
lua/
  config/          # Core configuration
    options.lua    # Neovim options
    keymaps.lua    # Keybindings
    autocmds.lua   # Auto commands
    globals.lua    # Global variables
    lazy.lua       # Plugin manager bootstrap
    lsp/
      tools.lua    # LSP servers, formatters, linters config
      diagnostics.lua
  plugins/         # Plugin specifications
    *.lua           # One file per plugin
```

#### Module Pattern
```lua
-- Return table for plugin specs
return {
  "author/plugin-name",
  dependencies = { "dep/plugin" },
  event = { "BufReadPre" },
  opts = {},
  config = function()
    -- setup code
  end,
}

-- Return table for modules with functions
local M = {}

M.setup = function()
  -- implementation
end

return M
```

#### Comments
- Section headers use `-- ====` format:
```lua
-- =============================================================================
-- TITLE : Plugin Name
-- ABOUT : Description
-- =============================================================================
```

#### Naming Conventions
- Plugins: lowercase with dashes (`nvim-lspconfig`)
- Tables/Functions: snake_case (`local function my_function()`)
- Variables: snake_case (`local config = {}`)
- Constants: SCREAMING_SNAKE_CASE (`local MAX_RETRIES = 5`)
- Keymap descriptions: Sentence case ("Move to left window")

#### Error Handling
- Use `pcall()` for potentially failing API calls:
```lua
pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
```
- Use `vim.fn` for external commands with shell_error check:
```lua
local out = vim.fn.system({ "git", "clone", repo, path })
if vim.v.shell_error ~= 0 then
  -- handle error
end
```

### Configuration File Conventions

#### Ghostty (config file)
- Use `#` for comments
- Key-value pairs: `key = value`
- No quotes needed for simple values

#### Tmux (tmux.conf)
- Use `#` for comments
- Commands use `-g` for global, `-w` for window options
- Variables use `#{}` syntax

#### Nushell (.nu files)
- Comments use `#`
- Commands are pipeline-based
- Environment variables: `$env.NAME`

### Plugin Configuration

#### Plugin Spec Structure
```lua
return {
  "author/plugin",
  enabled = true,  -- or false to disable
  dependencies = {},
  event = {},       -- or ft = {}, keys = {}, cmd = {}
  opts = {},       -- passed to setup()
  config = function(_, opts)
    require("plugin").setup(opts)
  end,
}
```

#### Lazy Plugin Loading
- Use `event` for file-type agnostic loading
- Use `ft` for filetype-specific loading
- Use `keys` for keymap-triggered loading
- Use `cmd` for command-triggered loading

### Keymaps Pattern
```lua
-- Basic keymap
vim.keymap.set("n", "<leader>key", "<cmd>Command<cr>", { desc = "Description" })

-- With options
vim.keymap.set("n", "<leader>key", function()
  -- code
end, { desc = "Description", buffer = bufnr })

-- Multi-mode
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yank" })
```

### Autocmd Pattern
```lua
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  desc = "Restore last cursor position",
  callback = function()
    -- code
  end,
})
```

## Directory Structure

```
dotfiles/
├── nvim/.config/nvim/     # Neovim configuration (primary)
│   ├── init.lua           # Entry point
│   ├── lua/
│   │   ├── config/        # Core settings
│   │   └── plugins/       # Plugin definitions
│   └── .luacheckrc        # Lua linter config
├── ghostty/.config/ghostty/  # Terminal config
│   ├── config             # Ghostty settings
│   ├── themes/            # Color themes
│   └── shaders/           # GLSL shaders
├── nushell/.config/nushell/  # Shell config
│   ├── config.nu          # Nushell config
│   └── env.nu             # Environment vars
└── tmux/.config/tmux/     # Terminal multiplexer
    ├── tmux.conf          # Tmux configuration
    └── plugins/           # TPM plugins
```

## Important Notes

1. **Blink.cmp Build**: blink-cmp requires `cargo build --release` - if editing, ensure Rust toolchain is installed.

2. **ts_ls Deduplication**: The LSP config has custom logic to prevent duplicate TypeScript language server instances.

3. **LSP/Formatter/Linter Tools**: Defined centrally in `lua/config/lsp/tools.lua` - add new tools there.

4. **Plugin Toggle**: Many plugins have `enabled = false` (e.g., conform, guard, nvim-lint) - enable by setting to `true`.

5. **Lazy Loading**: Most plugins are lazy-loaded - test changes with `:Lazy` command in Neovim.
