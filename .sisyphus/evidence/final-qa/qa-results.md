# Quickshell Integration QA — Final Evidence
Date: 2026-04-11

## Step 1: Treesitter Parser
Command: `nvim --headless -c 'lua local ok = pcall(vim.treesitter.language.require_language, "qmljs"); print(ok and "parser-found" or "parser-missing")' -c 'qa'`
Output: `parser-found`
Also confirmed: `lua/plugins/treesitter-modules.lua` has `"qmljs"` in ensure_installed
Result: **PASS**

## Step 2: Blink.cmp Source Loads
Command: `nvim --headless -c 'lua local ok, m = pcall(require, "sources.quickshell"); print(ok and "source-loaded" or "source-FAILED")' -c 'qa'`
Output: `source-loaded`
Result: **PASS**

## Step 3: Quickshell Completions Count
Command: `nvim --headless -c 'lua local m = require("sources.quickshell"); local s = m.new(); local count = 0; s:get_completions({}, function(res) count = #res.items end); print(count >= 15 and "completions-ok-"..count or "completions-FAIL-"..count)' -c 'qa'`
Output: `completions-ok-31`
Result: **PASS** (31 >= 15)

## Step 4: Per-Filetype Config
Command (corrected): `nvim --headless -c 'lua local cfg = require("blink.cmp.config"); local pft = cfg.sources.per_filetype; print(pft and pft.qml and "per-filetype-ok" or "per-filetype-MISSING")' -c 'qa'`
Output: `per-filetype-ok`
Full sources config for qml: `{ "quickshell", "lsp", "path", "snippets", "buffer" }`
Result: **PASS**

## Step 5: Snippets JSON Valid
Command: `python3 -c "import json; ... count/missing/generic check"`
Output: `count=10, missing=[], generic=[]`
Result: **PASS** (10 snippets, all required prefixes present, no generic QML names)

## Step 6: qmlls -E Flag
Command: `nvim --headless -c 'lua local c = vim.lsp.config.qmlls; print(c and c.cmd and c.cmd[2] == "-E" and "qmlls-E-ok" or "qmlls-E-MISSING")' -c 'qa'`
Output: `qmlls-E-ok`
Result: **PASS**

## Step 7: qmlls Excluded from Mason
Command: `nvim --headless -c 'lua local tools = require("config.lsp.tools"); ... print(has_qmlls and "qmlls-in-mason-BAD" or "qmlls-excluded-ok")' -c 'qa'`
Output: `qmlls-excluded-ok`
Result: **PASS**

## Summary
Treesitter PASS | Source PASS | Completions PASS | PerFiletype PASS | Snippets PASS | qmlls-E PASS | Mason-excluded PASS | VERDICT: APPROVE
