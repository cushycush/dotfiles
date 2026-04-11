- 2026-04-11: NeoVim LSP server metadata can safely carry custom fields like `mason = false` if plugin setup filters Mason installs separately and strips the metadata before handing configs to `vim.lsp.config`.
- 2026-04-11: `qmlls` should be registered with `cmd = { "qmlls", "-E" }` so it reads `QML_IMPORT_PATH` for Quickshell module resolution.

## Task 5: QML Snippets

- blink.cmp v1 built-in snippets source checks `~/.config/nvim/snippets/` by default
- To configure explicitly: `sources.providers.snippets.opts.search_paths = { vim.fn.stdpath("config") .. "/snippets" }`
- Requires `package.json` in the snippets dir mapping language to file path (VSCode format)
- `package.json` format: `{ "contributes": { "snippets": [{ "language": "qml", "path": "./qml.json" }] } }`
- Snippet body uses `\t` for indentation, `${n:placeholder}` for tab stops, `${0}` for final cursor
- 10 snippets all use `qs-*` prefix to avoid collision with Qt Quick builtins
