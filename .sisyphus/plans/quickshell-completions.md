# Quickshell QML Completion Support for NeoVim

## TL;DR

> **Quick Summary**: Add full QML/Quickshell editing support to NeoVim — LSP completions via qmlls, syntax highlighting via tree-sitter, a custom blink.cmp source for Quickshell-specific types that qmlls can't resolve, and snippet templates for common patterns.
>
> **Deliverables**:
> - qmlls LSP server configured with Quickshell module resolution (`-E` flag)
> - tree-sitter-qmljs parser for syntax highlighting
> - Custom blink.cmp completion source for Quickshell types/properties/signals
> - QML/Quickshell snippet templates (PanelWindow, Process, Variants, etc.)
> - Reusable non-Mason server infrastructure pattern in tools.lua
>
> **Estimated Effort**: Medium
> **Parallel Execution**: YES — 3 waves
> **Critical Path**: Task 1 → Task 4 → F1–F4

---

## Context

### Original Request
User wants completions for Quickshell in NeoVim. Their Quickshell config uses QML (Qt Modeling Language) — a declarative UI language with embedded JavaScript — for building desktop widgets on Hyprland/Wayland.

### Interview Summary
**Key Discussions**:
- User wants all 4 layers: qmlls LSP, tree-sitter highlighting, custom Quickshell completions, and snippets
- User is unsure if qmlls is installed (has Qt 6 but hasn't checked)
- This is a personal dotfiles repo — no CI, no test suite

**Research Findings**:
- **qmlls** (Qt official LSP) exists but cannot resolve Quickshell-specific types (PanelWindow, Process, Variants, etc.). Needs `-E` flag for `QML_IMPORT_PATH` environment variable.
- **tree-sitter-qmljs** (v0.3.0 by yuja) is actively maintained. Filetype: `qmljs`.
- **blink.cmp** custom providers follow a module pattern (see lazydev integration). Filetype restriction via `sources.per_filetype`.
- **No existing Quickshell NeoVim plugin** — this is greenfield.
- **qmlls is NOT in Mason's registry** — cannot use mason-lspconfig to install it. Ships with Qt 6.

### Metis Review
**Identified Gaps** (addressed):
- **nvim-lspconfig.lua merge loop only passes `settings` and `filetypes`** — won't propagate `cmd` for qmlls. Fix: generalize the merge to pass all server_config fields.
- **mason-lspconfig `ensure_installed` will break** — it reads all keys from tools.servers and tries to install via Mason. Fix: add `mason = false` field pattern and filter in mason-lspconfig.lua.
- **Treesitter config is in `treesitter-modules.lua`** (using treesitter-modules.nvim plugin), NOT in `treesitter.lua`.
- **blink.cmp filetype restriction** needs `sources.per_filetype`, not plugin `ft` field.

---

## Work Objectives

### Core Objective
Enable full QML/Quickshell editing experience in NeoVim with LSP intelligence, syntax highlighting, Quickshell-specific completions, and snippet templates.

### Concrete Deliverables
- Modified `config/lsp/tools.lua` — qmlls server entry with `mason = false` pattern
- Modified `plugins/mason-lspconfig.lua` — filters non-Mason servers from ensure_installed
- Modified `plugins/nvim-lspconfig.lua` — generalized merge loop passing all server_config fields
- Modified `plugins/treesitter-modules.lua` — `"qmljs"` added to ensure_installed
- Modified `plugins/blink-cmp.lua` — Quickshell provider registration + per_filetype config + snippet path
- New `sources/quickshell.lua` — custom blink.cmp provider for Quickshell types
- New snippet JSON file — QML/Quickshell patterns scoped to `qml` filetype

### Definition of Done
- [ ] Opening a `.qml` file in NeoVim shows syntax highlighting
- [ ] qmlls attaches to `.qml` files (when installed) providing Qt type completions
- [ ] Typing Quickshell-specific type names (e.g. `Panel`) triggers blink.cmp completions
- [ ] Snippet prefixes (e.g. `qs-panel`) expand into Quickshell scaffolds
- [ ] NeoVim starts cleanly with no errors (`nvim --headless "+Lazy! sync" +qa`)
- [ ] All existing LSP servers continue to work unchanged

### Must Have
- qmlls configured with `cmd = { "qmlls", "-E" }` for Quickshell module resolution
- Graceful handling when qmlls is not installed (no startup errors)
- Custom completion source scoped to `qml` filetype only
- Snippets limited to Quickshell-specific patterns (not generic Qt)
- Non-Mason server infrastructure pattern reusable for future servers

### Must NOT Have (Guardrails)
- Do NOT add QML formatters or linters (not requested)
- Do NOT modify any existing tools.servers entries or break existing LSP servers
- Do NOT expand completion source beyond types found in user's QML files + core Quickshell module imports
- Do NOT create hover documentation, signature help, or other LSP-adjacent features — qmlls handles those
- Do NOT fork or modify friendly-snippets upstream files
- Do NOT include generic QML/Qt Quick snippets (Rectangle, Column, Row) — those come from qmlls
- Do NOT use Vimscript — everything is Lua
- Do NOT hardcode border characters — use `utils/chars.lua` if borders are needed

---

## Verification Strategy

> **ZERO HUMAN INTERVENTION** — ALL verification is agent-executed. No exceptions.

### Test Decision
- **Infrastructure exists**: NO (dotfiles repo)
- **Automated tests**: None
- **Framework**: N/A

### QA Policy
Every task MUST include agent-executed QA scenarios using `nvim --headless` commands.
Evidence saved to `.sisyphus/evidence/task-{N}-{scenario-slug}.{ext}`.

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately — foundation + independent features):
├── Task 1: Non-Mason server infrastructure [deep]
│   (mason-lspconfig.lua filter + nvim-lspconfig.lua merge generalization)
├── Task 2: Tree-sitter QML parser [quick]
│   (add qmljs to treesitter-modules.lua)
└── Task 3: Quickshell blink.cmp completion source [deep]
    (create sources/quickshell.lua + register in blink-cmp.lua)

Wave 2 (After Wave 1 — depends on infrastructure + blink-cmp.lua):
├── Task 4: qmlls LSP server setup [quick]
│   (add to tools.lua, depends: Task 1)
└── Task 5: QML/Quickshell snippets [unspecified-high]
    (create snippet JSON + configure path, depends: Task 3 for blink-cmp.lua)

Wave FINAL (After ALL tasks — 4 parallel reviews, then user okay):
├── Task F1: Plan compliance audit (oracle)
├── Task F2: Code quality review (unspecified-high)
├── Task F3: Real manual QA (unspecified-high)
└── Task F4: Scope fidelity check (deep)
-> Present results -> Get explicit user okay
```

### Dependency Matrix

| Task | Depends On | Blocks | Wave |
|------|-----------|--------|------|
| 1 | — | 4 | 1 |
| 2 | — | — | 1 |
| 3 | — | 5 | 1 |
| 4 | 1 | — | 2 |
| 5 | 3 | — | 2 |

### Agent Dispatch Summary

- **Wave 1**: **3** — T1 → `deep`, T2 → `quick`, T3 → `deep`
- **Wave 2**: **2** — T4 → `quick`, T5 → `unspecified-high`
- **FINAL**: **4** — F1 → `oracle`, F2 → `unspecified-high`, F3 → `unspecified-high`, F4 → `deep`

---

## TODOs

- [x] 1. Non-Mason Server Infrastructure

  **What to do**:
  - Modify `NeoVim/lua/plugins/mason-lspconfig.lua` to filter out servers with `mason = false` from `ensure_installed`. Currently it does `ensure_installed = vim.tbl_keys(require("config.lsp.tools").servers)` which will break when non-Mason servers (like qmlls) are added.
  - Change the filter to iterate with `pairs()` preserving server names: build a list of server names where `cfg.mason ~= false`, e.g.:
    ```lua
    local tools = require("config.lsp.tools")
    local mason_servers = {}
    for name, cfg in pairs(tools.servers) do
      if cfg.mason ~= false then
        table.insert(mason_servers, name)
      end
    end
    ```
    Then pass `mason_servers` to `ensure_installed`. Note: `vim.tbl_filter()` on a keyed table produces a numeric list of VALUES (losing server names), so do NOT use it here.
  - Modify `NeoVim/lua/plugins/nvim-lspconfig.lua` merge loop to pass ALL server_config fields to `vim.lsp.config`, not just `settings` and `filetypes`. Currently the loop explicitly destructures only those two fields, which means `cmd` overrides won't propagate.
  - The new merge should deep-extend the base_config with the entire server_config (minus our custom `mason` field), plus `on_attach`.
  - Strip the `mason` field before passing to lspconfig (it is our custom metadata, not a valid lspconfig option).
  - Also modify `NeoVim/lua/config/lsp/tools.lua` `get_all_binaries()` function (lines 89-109) to skip servers with `mason = false`. Currently it iterates ALL `M.servers` entries and adds their names to the install list. Without this fix, `mason-tool-installer.lua` (which calls `get_all_binaries()`) will still try to install qmlls via Mason.
  - In the loop `for server, _ in pairs(M.servers)`, add a guard: `if M.servers[server].mason ~= false then table.insert(all, server) end`.

  **Must NOT do**:
  - Do NOT change behavior for any existing servers -- this is a backward-compatible infrastructure change
  - Do NOT remove or modify any existing server entries in tools.lua
  - Do NOT change `automatic_enable = false` in mason-lspconfig

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Modifying two interconnected config files that affect all LSP servers -- needs careful reasoning about backward compatibility
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 2, 3)
  - **Blocks**: Task 4 (qmlls depends on this infrastructure)
  - **Blocked By**: None (can start immediately)

  **References**:

  **Pattern References**:
  - `NeoVim/lua/plugins/nvim-lspconfig.lua:91-102` -- The merge loop that iterates `tools.servers` and currently only passes `settings` and `filetypes`. This is what needs generalization to pass all fields.
  - `NeoVim/lua/plugins/mason-lspconfig.lua:8` -- The `ensure_installed` line that reads all keys from tools.servers. This needs filtering to exclude `mason = false` entries.
  - `NeoVim/lua/plugins/mason-tool-installer.lua:7` -- Calls `require("config.lsp.tools").get_all_binaries()` which also iterates all servers. The `get_all_binaries()` function in tools.lua must be updated to skip `mason = false` servers.
  - `NeoVim/lua/config/lsp/tools.lua:89-109` -- The `get_all_binaries()` function. Its server loop at line 92 needs the `mason ~= false` guard.

  **API/Type References**:
  - `NeoVim/lua/config/lsp/tools.lua:3-49` -- The `M.servers` table structure. Each key is a server name, value is config. The new `mason = false` field will be added here for non-Mason servers.

  **Why Each Reference Matters**:
  - `nvim-lspconfig.lua:91-102`: Shows the exact merge pattern that needs changing. The agent must understand that `vim.lsp.config[server]` is being extended with only `on_attach`, `settings`, `filetypes` -- and needs to extend with ALL fields from tools.servers.
  - `mason-lspconfig.lua:8`: Shows the one-liner that creates `ensure_installed` -- needs a `vim.tbl_filter` wrapper.
  - `tools.lua:3-49`: Shows existing server structure so agent understands backward compatibility.

  **QA Scenarios**:

  ```
  Scenario: Existing servers unaffected after infrastructure change
    Tool: Bash (nvim --headless)
    Preconditions: NeoVim config modified with generalized merge loop
    Steps:
      1. Run: nvim --headless -c 'lua local t = require("config.lsp.tools"); local keys = vim.tbl_keys(t.servers); table.sort(keys); print(table.concat(keys, ","))' -c 'qa'
      2. Assert output contains: bashls,clangd,dockerls,emmet_ls,gopls,jsonls,lua_ls,pyright,tailwindcss,ts_ls,yamlls
      3. Run: nvim --headless -c 'lua local c = vim.lsp.config.lua_ls; print(c and c.name or "nil")' -c 'qa'
      4. Assert output is not "nil" (lua_ls config still loads)
    Expected Result: All 11 existing servers present in tools.servers; lua_ls config resolves
    Failure Indicators: Missing servers, nil config, startup errors
    Evidence: .sisyphus/evidence/task-1-existing-servers.txt

  Scenario: mason-lspconfig filters non-Mason servers
    Tool: Bash (nvim --headless)
    Preconditions: Modified mason-lspconfig.lua with filter
    Steps:
      1. Run: nvim --headless "+Lazy! sync" +qa 2>&1
      2. Assert exit code is 0
      3. Assert no "mason" errors in output
    Expected Result: Clean startup with no mason-lspconfig errors
    Failure Indicators: Error messages mentioning mason, non-zero exit code
    Evidence: .sisyphus/evidence/task-1-mason-filter.txt
  ```

  **Commit**: YES
  - Message: `feat(lsp): support non-Mason LSP servers in tools.lua`
  - Files: `NeoVim/lua/plugins/mason-lspconfig.lua`, `NeoVim/lua/plugins/nvim-lspconfig.lua`, `NeoVim/lua/config/lsp/tools.lua`
  - Pre-commit: `nvim --headless "+Lazy! sync" +qa`

- [x] 2. Tree-sitter QML Parser

  **What to do**:
  - Add `"qmljs"` to the `ensure_installed` list in `NeoVim/lua/plugins/treesitter-modules.lua`
  - Place it alphabetically in the list (after `json`, before `lua`)
  - The plugin already has `auto_install = true`, so this ensures the parser is installed proactively

  **Must NOT do**:
  - Do NOT modify `treesitter.lua` -- that is just the base plugin spec with build command
  - Do NOT change any existing treesitter settings (highlight, indent, incremental_selection)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Single-line addition to an existing list
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 3)
  - **Blocks**: None
  - **Blocked By**: None (can start immediately)

  **References**:

  **Pattern References**:
  - `NeoVim/lua/plugins/treesitter-modules.lua:5-21` -- The `ensure_installed` list. Add `"qmljs"` between `"json"` and `"lua"`.

  **External References**:
  - tree-sitter-qmljs: https://github.com/yuja/tree-sitter-qmljs -- Parser registered in nvim-treesitter as `qmljs`.

  **QA Scenarios**:

  ```
  Scenario: qmljs parser in ensure_installed list
    Tool: Bash (grep + nvim)
    Steps:
      1. Run: grep -c '"qmljs"' NeoVim/lua/plugins/treesitter-modules.lua
      2. Assert output is "1"
      3. Run: nvim --headless "+Lazy! sync" +qa 2>&1
      4. Assert exit code is 0
    Expected Result: qmljs appears exactly once; clean startup
    Evidence: .sisyphus/evidence/task-2-qmljs-installed.txt

  Scenario: Existing parsers preserved
    Tool: Bash (grep)
    Steps:
      1. Run: grep -c '"lua"' NeoVim/lua/plugins/treesitter-modules.lua
      2. Assert output is "1"
      3. Count total entries in ensure_installed -- should be 16 (15 original + qmljs)
    Expected Result: All original parsers still present
    Evidence: .sisyphus/evidence/task-2-parsers-preserved.txt
  ```

  **Commit**: YES
  - Message: `feat(treesitter): add QML parser`
  - Files: `NeoVim/lua/plugins/treesitter-modules.lua`
  - Pre-commit: `nvim --headless "+Lazy! sync" +qa`

- [x] 3. Quickshell blink.cmp Completion Source

  **What to do**:
  - Create `NeoVim/lua/sources/quickshell.lua` — a custom blink.cmp provider module implementing the source interface (`new()` constructor + `get_completions()` method).
  - The module should contain a data table of Quickshell-specific completion items covering:
    - **Window types**: `PanelWindow`, `FloatingWindow`, `PopupWindow` — with common properties (anchors, implicitHeight/Width, color, visible, etc.)
    - **Core types**: `Scope`, `Variants` — with their specific properties (model, delegate)
    - **I/O types**: `Process` (command, running, onExited, stdout), `FileView` (path, text, onTextChanged), `StdioCollector` (onStreamFinished, text)
    - **Wayland types**: `WlrLayershell`, `WlrLayer`, `WlrKeyboardFocus`, `ExclusionMode`, `ScreencopyView`
    - **Hyprland types**: `Hyprland.focusedMonitor`, `Hyprland.monitors`
    - **Global API**: `Quickshell.screens`, `Quickshell.env()`, `Quickshell.execDetached()`, `Quickshell.cachePath()`, `Quickshell.shellDir`
    - **Import paths**: `Quickshell`, `Quickshell.Hyprland`, `Quickshell.Io`, `Quickshell.Wayland`, `Quickshell.Widgets`
  - Each completion item needs: `label` (the completion text), `kind` (Class/Property/Function/Module as appropriate), `detail` (brief type info), `documentation` (one-line description).
  - Follow the `local M = {} ... return M` module pattern.
  - Register the provider in `NeoVim/lua/plugins/blink-cmp.lua`:
    - Add to `sources.providers`: `quickshell = { name = "Quickshell", module = "sources.quickshell", score_offset = 90 }`
    - Add `sources.per_filetype` config: `qml = { "quickshell", "lsp", "path", "snippets", "buffer" }`
  - Research the exact blink.cmp provider interface (check blink.cmp docs or source) to ensure the module implements it correctly. The lazydev integration at `lazydev.integrations.blink` is the closest reference.

  **Must NOT do**:
  - Do NOT include Qt Quick types (Rectangle, Text, MouseArea, etc.) — qmlls provides those
  - Do NOT create hover documentation or signature help — qmlls handles that
  - Do NOT make the source available for non-QML filetypes
  - Do NOT over-document entries — keep descriptions to one line each

  **Recommended Agent Profile**:
  - **Category**: `deep`
    - Reason: Requires researching blink.cmp provider API, creating a complete data-driven module, and correctly integrating with existing blink-cmp.lua config
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 2)
  - **Blocks**: Task 5 (snippets also modifies blink-cmp.lua)
  - **Blocked By**: None (can start immediately)

  **References**:

  **Pattern References**:
  - `NeoVim/lua/plugins/blink-cmp.lua:13-28` -- Current sources config with lazydev provider. Shows registration pattern: `providers = { lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 } }`. Follow this exact pattern for the quickshell provider.
  - `NeoVim/lua/plugins/blink-cmp.lua:57-58` -- `opts_extend = { "sources.default" }` — understand how sources can be extended per-filetype.
  - `NeoVim/lua/utils/neovim.lua` -- Example of `local M = {} ... return M` module pattern used in this codebase.

  **API/Type References**:
  - blink.cmp source interface — Research via `codesearch` or `librarian`. The provider module must export a table with `new()` and `get_completions(context, callback)` methods. Each completion item uses LSP CompletionItem fields.

  **Content References** (Quickshell types to include — extracted from user's QML files):
  - `Quickshell/HyprQuickFrame/shell.qml` -- Uses: Scope, Variants, Process, FileView, FloatingWindow, Hyprland.focusedMonitor, Quickshell.screens, Quickshell.env(), Quickshell.execDetached()
  - `Quickshell/HyprQuickFrame/components/FreezeScreen.qml` -- Uses: PanelWindow, WlrLayershell, ScreencopyView, WlrLayer, WlrKeyboardFocus, ExclusionMode
  - `Quickshell/HyprQuickFrame/components/RegionSelector.qml` -- Uses: Canvas, ShaderEffect (Qt types — skip these), property declarations, signal declarations
  - `Quickshell/HyprQuickFrame/components/Theme.qml` -- Uses: QtObject (Qt — skip), custom properties

  **Why Each Reference Matters**:
  - `blink-cmp.lua:13-28`: Exact pattern for provider registration. Agent must add quickshell provider following this structure.
  - `shell.qml`: Primary source for what Quickshell types the user actually uses. Completion data should cover these.
  - `FreezeScreen.qml`: Shows Wayland layer-shell types that need completions.

  **QA Scenarios**:

  ```
  Scenario: Custom source module loads correctly
    Tool: Bash (nvim --headless)
    Steps:
      1. Run: nvim --headless -c 'lua local ok, m = pcall(require, "sources.quickshell"); print(ok, type(m))' -c 'qa'
      2. Assert output contains: true	table
      3. Run: nvim --headless -c 'lua local m = require("sources.quickshell"); local s = m.new(); print(type(s.get_completions))' -c 'qa'
      4. Assert output is "function"
    Expected Result: Module loads, exports new() constructor, instance has get_completions method
    Failure Indicators: pcall returns false, or methods missing
    Evidence: .sisyphus/evidence/task-3-source-loads.txt

  Scenario: Provider registered in blink-cmp config
    Tool: Bash (grep)
    Steps:
      1. Run: grep -c 'quickshell' NeoVim/lua/plugins/blink-cmp.lua
      2. Assert output is >= 2 (provider entry + per_filetype entry)
      3. Run: grep 'per_filetype' NeoVim/lua/plugins/blink-cmp.lua
      4. Assert output contains "qml"
    Expected Result: quickshell provider and per_filetype config present in blink-cmp.lua
    Evidence: .sisyphus/evidence/task-3-provider-registered.txt

  Scenario: Completion data covers expected types
    Tool: Bash (nvim --headless)
    Steps:
      1. Run: nvim --headless -c 'lua local m = require("sources.quickshell"); local s = m.new(); s:get_completions({}, function(items) print(#items.items) end)' -c 'qa'
      2. Assert output is a number >= 15 (minimum types/properties/APIs)
      3. Run: grep -c 'PanelWindow' NeoVim/lua/sources/quickshell.lua
      4. Assert output >= 1
      5. Run: grep -c 'Quickshell.screens' NeoVim/lua/sources/quickshell.lua
      6. Assert output >= 1
    Expected Result: Source provides 15+ completion items covering window types, I/O, and global API
    Evidence: .sisyphus/evidence/task-3-completion-data.txt
  ```

  **Commit**: YES
  - Message: `feat(completion): add Quickshell blink.cmp source`
  - Files: `NeoVim/lua/sources/quickshell.lua`, `NeoVim/lua/plugins/blink-cmp.lua`
  - Pre-commit: `nvim --headless -c 'lua pcall(require, "sources.quickshell")' -c 'qa'`

- [x] 4. qmlls LSP Server Setup

  **What to do**:
  - Add qmlls entry to `NeoVim/lua/config/lsp/tools.lua` M.servers table:
    ```lua
    qmlls = {
      cmd = { "qmlls", "-E" },
      filetypes = { "qml" },
      mason = false,
    },
    ```
  - The `-E` flag enables reading `QML_IMPORT_PATH` from environment, which is how qmlls discovers Quickshell modules.
  - The `mason = false` flag ensures mason-lspconfig skips installation (handled by Task 1 infrastructure).
  - Add a helpful notification when qmlls is not found. In `NeoVim/lua/plugins/nvim-lspconfig.lua`, wrap the qmlls enable with an executable check:
    - Before calling `vim.lsp.enable()`, check `vim.fn.executable("qmlls") == 1`. If not found, use `vim.notify()` once to suggest installing Qt 6 QML tools.
    - Alternatively, this check can live in the loop that processes servers — skip servers with `mason = false` where the cmd binary is not on PATH, with a one-time notification.

  **Must NOT do**:
  - Do NOT add qmlls to formatters or linters tables
  - Do NOT modify any existing server entries
  - Do NOT add a .qmlls.ini file (Quickshell auto-generates this at runtime)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Small additions to two existing config files following established patterns
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Task 5)
  - **Blocks**: None
  - **Blocked By**: Task 1 (needs non-Mason server infrastructure)

  **References**:

  **Pattern References**:
  - `NeoVim/lua/config/lsp/tools.lua:3-49` -- Existing M.servers table. Add qmlls entry following the same structure. Note that qmlls is the first server with explicit `cmd` and `mason = false`.
  - `NeoVim/lua/plugins/nvim-lspconfig.lua:91-102` -- The merge loop (already generalized by Task 1). After Task 1, this loop will correctly pass `cmd` to vim.lsp.config. The executable check should be added here or just before `vim.lsp.enable()`.

  **External References**:
  - qmlls docs: Ships with Qt 6. The `-E` flag (available in qmlls 6.8.2+) enables reading QML_IMPORT_PATH from the environment for module resolution.

  **Why Each Reference Matters**:
  - `tools.lua:3-49`: Shows where to add the new entry and the existing pattern to follow.
  - `nvim-lspconfig.lua:91-102`: Shows where the executable guard should be added.

  **QA Scenarios**:

  ```
  Scenario: qmlls config registered correctly
    Tool: Bash (nvim --headless)
    Steps:
      1. Run: nvim --headless -c 'lua print(vim.inspect(vim.lsp.config.qmlls))' -c 'qa'
      2. Assert output contains "qmlls" and "-E"
      3. Run: nvim --headless -c 'lua local t = require("config.lsp.tools"); print(t.servers.qmlls and "exists" or "missing")' -c 'qa'
      4. Assert output is "exists"
    Expected Result: qmlls registered in both tools.lua and vim.lsp.config with -E flag
    Failure Indicators: nil config, missing -E flag
    Evidence: .sisyphus/evidence/task-4-qmlls-config.txt

  Scenario: mason-lspconfig ignores qmlls
    Tool: Bash (nvim --headless)
    Steps:
      1. Run: nvim --headless "+Lazy! sync" +qa 2>&1
      2. Assert no errors about qmlls or mason
    Expected Result: Clean startup even though qmlls is not in Mason registry
    Failure Indicators: Mason errors, non-zero exit code
    Evidence: .sisyphus/evidence/task-4-mason-clean.txt

  Scenario: Graceful handling when qmlls not installed
    Tool: Bash (nvim --headless)
    Preconditions: qmlls may or may not be on PATH
    Steps:
      1. Run: nvim --headless -c 'lua print(vim.fn.executable("qmlls"))' -c 'qa'
      2. If output is "0" (not installed): verify NeoVim starts cleanly with no errors
      3. If output is "1" (installed): verify qmlls appears in lsp.get_clients when opening a .qml file
    Expected Result: No crash regardless of qmlls installation status
    Evidence: .sisyphus/evidence/task-4-graceful-missing.txt
  ```

  **Commit**: YES
  - Message: `feat(lsp): add qmlls for QML/Quickshell`
  - Files: `NeoVim/lua/config/lsp/tools.lua`, `NeoVim/lua/plugins/nvim-lspconfig.lua`
  - Pre-commit: `nvim --headless "+Lazy! sync" +qa`

- [x] 5. QML/Quickshell Snippet Templates

  **What to do**:
  - Research where blink.cmp's snippets source looks for custom snippet files. Check `blink.cmp` documentation for the snippets provider `opts.search_paths` configuration. Custom snippets likely go in a directory that blink.cmp's snippet engine discovers.
  - Create a snippet JSON file (e.g., `NeoVim/snippets/qml.json`) with Quickshell-specific templates scoped to `qml` filetype. Use friendly-snippets JSON format:
    ```json
    {
      "Quickshell PanelWindow": {
        "prefix": "qs-panel",
        "body": [
          "PanelWindow {",
          "\tanchors {\n\t\ttop: true\n\t\tleft: true\n\t\tright: true\n\t}",
          "\timplicitHeight: ",
          "\n\t/usr/bin/bash",
          "}"
        ],
        "description": "Quickshell PanelWindow scaffold"
      }
    }
    ```
  - Include snippets for these patterns (extracted from user's actual QML code):
    - `qs-panel` — PanelWindow with anchors + implicitHeight
    - `qs-float` — FloatingWindow scaffold
    - `qs-scope` — Scope root element
    - `qs-process` — Process with command, onExited, StdioCollector
    - `qs-fileview` — FileView with path and onTextChanged
    - `qs-variants` — Variants with model and required property modelData
    - `qs-layershell` — WlrLayershell config (layer, keyboardFocus, exclusionMode)
    - `qs-timer` — Timer with interval and onTriggered
    - `qs-prop` — Property declaration (property type name: default)
    - `qs-signal` — Signal declaration with parameters
  - Configure blink.cmp to discover the custom snippets directory. Update `NeoVim/lua/plugins/blink-cmp.lua` to add the snippets search path.

  **Must NOT do**:
  - Do NOT include generic Qt Quick snippets (Rectangle, Column, Row, etc.)
  - Do NOT fork or modify friendly-snippets upstream package
  - Do NOT add more than ~12 snippets — keep it focused on Quickshell patterns

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Requires research into blink.cmp snippet path configuration, creating well-structured JSON, and integration testing
  - **Skills**: `[]`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Task 4)
  - **Blocks**: None
  - **Blocked By**: Task 3 (blink-cmp.lua was modified in Task 3; this task makes further edits to the same file)

  **References**:

  **Pattern References**:
  - `NeoVim/lua/plugins/blink-cmp.lua:3-5` -- friendly-snippets dependency. Shows snippets are already configured as a source.
  - `NeoVim/lua/plugins/blink-cmp.lua:14-19` -- default sources list includes "snippets". Custom snippets need to be discoverable by this source.

  **Content References** (patterns to create snippets from):
  - `Quickshell/HyprQuickFrame/shell.qml:1-30` -- Scope root + Variants + Process pattern
  - `Quickshell/HyprQuickFrame/components/FreezeScreen.qml:1-30` -- PanelWindow + WlrLayershell pattern
  - `Quickshell/HyprQuickFrame/components/Theme.qml` -- Property declaration pattern
  - `Quickshell/HyprQuickFrame/components/RegionSelector.qml` -- Signal + Timer patterns

  **External References**:
  - blink.cmp snippets documentation — Search for how to configure custom snippet directories. Key config: `sources.providers.snippets.opts.search_paths` or similar.

  **Why Each Reference Matters**:
  - `blink-cmp.lua`: Shows current snippet config. Agent needs to add custom path without breaking friendly-snippets.
  - QML files: Each contains a concrete pattern that becomes a snippet. Agent should read these to create accurate scaffolds.

  **QA Scenarios**:

  ```
  Scenario: Snippet JSON file is valid
    Tool: Bash (nvim --headless)
    Steps:
      1. Run: nvim --headless -c 'lua local f = io.open("NeoVim/snippets/qml.json"); local j = vim.json.decode(f:read("*a")); f:close(); print(vim.tbl_count(j))' -c 'qa'
      2. Assert output is a number >= 8 (minimum 8 snippets)
      3. Run: nvim --headless -c 'lua local f = io.open("NeoVim/snippets/qml.json"); local j = vim.json.decode(f:read("*a")); f:close(); for k,v in pairs(j) do assert(v.prefix, k.." missing prefix"); assert(v.body, k.." missing body") end; print("valid")' -c 'qa'
      4. Assert output is "valid"
    Expected Result: JSON parses cleanly, all snippets have prefix and body fields, 8+ snippets present
    Failure Indicators: JSON parse error, missing fields, fewer than 8 snippets
    Evidence: .sisyphus/evidence/task-5-snippets-valid.txt

  Scenario: Snippets are QML-scoped
    Tool: Bash (grep)
    Steps:
      1. Run: grep -c 'qs-panel' NeoVim/snippets/qml.json
      2. Assert output >= 1
      3. Run: grep -c 'qs-process' NeoVim/snippets/qml.json
      4. Assert output >= 1
    Expected Result: Key Quickshell snippet prefixes present
    Evidence: .sisyphus/evidence/task-5-snippets-scoped.txt

  Scenario: No generic Qt snippets included
    Tool: Bash (grep)
    Steps:
      1. Search snippet file for generic Qt type names as snippet prefixes
      2. Run: grep -E '"prefix".*"(rect|column|row|text)"' NeoVim/snippets/qml.json | wc -l
      3. Assert output is "0"
    Expected Result: No generic Qt Quick snippets (Rectangle, Column, Row, Text) in the file
    Failure Indicators: Generic Qt snippets found
    Evidence: .sisyphus/evidence/task-5-no-generic-qt.txt
  ```

  **Commit**: YES
  - Message: `feat(snippets): add QML/Quickshell snippet templates`
  - Files: `NeoVim/snippets/qml.json`, `NeoVim/lua/plugins/blink-cmp.lua`
  - Pre-commit: `nvim --headless "+Lazy! sync" +qa`

---

## Final Verification Wave

> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.

- [x] F1. **Plan Compliance Audit** — `oracle`
  Read the plan end-to-end. For each "Must Have": verify implementation exists (read files, check config entries). For each "Must NOT Have": search codebase for forbidden patterns — reject with file:line if found. Check evidence files exist in `.sisyphus/evidence/`. Compare deliverables against plan.
  Output: `Must Have [N/N] | Must NOT Have [N/N] | Tasks [N/N] | VERDICT: APPROVE/REJECT`

- [x] F2. **Code Quality Review** — `unspecified-high`
  Open NeoVim headless and verify clean startup. Review all changed/new files for: empty error handlers, commented-out code, unused requires. Check AI slop: excessive comments, over-abstraction, generic variable names. Verify all Lua files follow `local M = {} ... return M` pattern. Verify tabs for indentation.
  Output: `Startup [PASS/FAIL] | Files [N clean/N issues] | VERDICT`

- [x] F3. **Agent-Executed Integration QA** — `unspecified-high` (skills: `[playwright]`)
  Use `interactive_bash` (tmux) to open NeoVim with a `.qml` file and verify integration end-to-end:
  1. Start tmux session, open `nvim Quickshell/HyprQuickFrame/shell.qml`
  2. Verify treesitter highlighting: run `:lua print(vim.treesitter.get_parser():lang())` — assert output is `qmljs`
  3. Verify blink.cmp source active: enter insert mode, type `Panel`, capture completion menu — assert `PanelWindow` appears (from custom source)
  4. Verify snippet expansion: type `qs-panel` + trigger completion — assert `PanelWindow {` scaffold appears
  5. If qmlls on PATH: run `:lua print(#vim.lsp.get_clients({bufnr=0}))` — assert >= 1
  6. If qmlls not on PATH: run same command — assert 0 (no crash)
  7. Capture each result to `.sisyphus/evidence/final-qa/` as text files
  All steps MUST be automated via tmux send-keys. No human interaction.
  Output: `Highlighting [PASS/FAIL] | Completions [PASS/FAIL] | Snippets [PASS/FAIL] | LSP [PASS/FAIL/SKIPPED] | VERDICT`

- [x] F4. **Scope Fidelity Check** — `deep`
  For each task: read "What to do", read actual diff. Verify 1:1 — everything in spec was built (no missing), nothing beyond spec was built (no creep). Check "Must NOT do" compliance. Flag unaccounted changes.
  Output: `Tasks [N/N compliant] | Unaccounted [CLEAN/N files] | VERDICT`

---

## Commit Strategy

| # | Message | Files | Pre-commit |
|---|---------|-------|------------|
| 1 | `feat(lsp): support non-Mason LSP servers in tools.lua` | `mason-lspconfig.lua`, `nvim-lspconfig.lua` | `nvim --headless "+Lazy! sync" +qa` |
| 2 | `feat(treesitter): add QML parser` | `treesitter-modules.lua` | `nvim --headless "+Lazy! sync" +qa` |
| 3 | `feat(completion): add Quickshell blink.cmp source` | `sources/quickshell.lua`, `blink-cmp.lua` | `nvim --headless -c 'lua pcall(require, "sources.quickshell")' -c 'qa'` |
| 4 | `feat(lsp): add qmlls for QML/Quickshell` | `config/lsp/tools.lua` | `nvim --headless "+Lazy! sync" +qa` |
| 5 | `feat(snippets): add QML/Quickshell snippet templates` | snippet JSON, `blink-cmp.lua` | `nvim --headless "+Lazy! sync" +qa` |

---

## Success Criteria

### Verification Commands
```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless -c 'lua print(vim.inspect(vim.lsp.config.qmlls))' -c 'qa'
nvim --headless -c 'lua local ok, m = pcall(require, "sources.quickshell"); print(ok)' -c 'qa'
nvim --headless -c 'lua print(vim.inspect(vim.tbl_keys(require("config.lsp.tools").servers)))' -c 'qa'
```

### Final Checklist
- [ ] All "Must Have" present
- [ ] All "Must NOT Have" absent
- [ ] NeoVim starts cleanly
- [ ] Existing LSP servers unaffected
- [ ] `.qml` files get syntax highlighting + completions
