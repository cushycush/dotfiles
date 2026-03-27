# AGENTS.md - Dotfiles Development Guide

Dotfiles repository for Neovim (Lua primary), Ghostty, Nushell, and Tmux configurations.

## Lint/Format/Validate Commands

### Lua (Neovim config in `nvim/.config/nvim/`)

```bash
# Format all Lua files
cd nvim/.config/nvim && stylua lua/

# Format specific file
stylua lua/plugins/nvim-lspconfig.lua

# Check formatting without modifying
stylua --check lua/

# Validate Neovim config loads
nvim --headless -c 'quit' 2>&1

# Validate specific module loads
nvim --headless -c 'lua require("config.lsp.tools")' -c 'quit'
```

### Other Configurations

```bash
# Lint shell scripts
shellcheck tmux/.config/tmux/plugins/tpm/bin/*.sh

# Check Ghostty config syntax
ghostty --config-file=ghostty/.config/ghostty/config
```

## Code Style Guidelines

### Lua Conventions

**Indentation & Formatting:**
- 2 spaces (no tabs), single newline at EOF
- Use `vim.opt` not `vim.o` / `vim.go`
- All keymaps: `vim.keymap.set()` with `desc` option
- All autocmds: `vim.api.nvim_create_autocmd()` with `desc`
- Capture functions in closures before reassignment to avoid linter warnings

**Naming:**
- Plugins: lowercase-dashes (`nvim-lspconfig`)
- Functions/variables: snake_case (`local my_function()`)
- Constants: SCREAMING_SNAKE_CASE (`MAX_RETRIES`)
- Keymap descriptions: Sentence case ("Move to left window")

**Comments:**
- Section headers: 80-char line with `-- TITLE : Description`
- Inline comments for non-obvious logic
- Lua LSP diagnostics suppressed with named diagnostic codes (e.g., `@diagnostic disable-next-line: duplicate-set-field`)

**Error Handling:**
```lua
-- Wrap potentially failing API calls
pcall(vim.api.nvim_win_set_cursor, 0, {1, 0})

-- Check external command return codes
local out = vim.fn.system({"git", "clone", url, path})
if vim.v.shell_error ~= 0 then error("Clone failed") end
```

### File Structure

```
lua/
├── config/
│   ├── options.lua        # Neovim options (vim.opt)
│   ├── keymaps.lua        # Global keybindings
│   ├── autocmds.lua       # Auto commands
│   ├── globals.lua        # Global variables
│   ├── lazy.lua           # Plugin manager bootstrap
│   ├── highlights.lua     # Theme/highlight overrides
│   └── lsp/
│       ├── tools.lua      # Central LSP/formatter/linter config
│       └── diagnostics.lua
└── plugins/
    └── *.lua              # One plugin spec per file
```

### Plugin Module Pattern

```lua
-- Plugin spec (returns table with spec properties)
return {
  "author/plugin-name",
  dependencies = { "dep/plugin" },
  event = "BufReadPre",     -- or ft, keys, cmd for lazy loading
  opts = {},                -- passed to setup()
  config = function(_, opts)
    require("plugin").setup(opts)
  end,
}

-- Utility module (returns M with functions)
local M = {}
M.setup = function() end
return M
```

### Keymap & Autocmd Patterns

```lua
-- Keymap with description
vim.keymap.set("n", "<leader>x", "<cmd>Cmd<cr>", { desc = "Action" })

-- Autocmd with group
local group = vim.api.nvim_create_augroup("MyGroup", { clear = true })
vim.api.nvim_create_autocmd("BufRead", {
  group = group,
  desc = "Description",
  callback = function() end,
})
```

## Directory Structure

```
dotfiles/
├── nvim/.config/nvim/          # Neovim (primary focus)
│   ├── init.lua
│   ├── lua/{config,plugins}/
│   ├── .luacheckrc             # Lua linter config
│   └── .luarc.json             # Lua LSP config
├── ghostty/.config/ghostty/    # Terminal config
├── nushell/.config/nushell/    # Shell environment
└── tmux/.config/tmux/          # Terminal multiplexer
```

## Key Implementation Details

1. **Lua Diagnostics**: Lua LSP is the source of truth for Lua diagnostics (via lua_ls server). Suppress with `@diagnostic disable-next-line: diagnostic-name`.

2. **Central Tool Config**: All LSP servers, formatters, linters defined in `lua/config/lsp/tools.lua`.

3. **Blink.cmp**: Build requires `cargo build --release` - ensure Rust toolchain present.

4. **ts_ls Deduplication**: Custom wrapper in `lua/plugins/nvim-lspconfig.lua` prevents duplicate TypeScript server instances.

5. **Plugin Toggle**: Many plugins disabled (`enabled = false`) - enable by setting to `true`.

6. **Lazy Loading**: Most plugins lazy-load by event/filetype/keymap. Test changes with `:Lazy` command.
