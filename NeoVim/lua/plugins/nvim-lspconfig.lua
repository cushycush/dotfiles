return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"saghen/blink.cmp",
	},
	config = function()
		local tools = require("config.lsp.tools")
		local C = require("utils.chars")

		-- Semantic token priority (just below treesitter)
		vim.highlight.priorities.semantic_tokens = 99

		-- Diagnostic configuration
		vim.diagnostic.config({
			virtual_lines = false,
			virtual_text = false,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = C.diagnostic_signs.error,
					[vim.diagnostic.severity.WARN] = C.diagnostic_signs.warn,
					[vim.diagnostic.severity.INFO] = C.diagnostic_signs.info,
					[vim.diagnostic.severity.HINT] = C.diagnostic_signs.hint,
				},
				numhl = {
					[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
					[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
					[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
					[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
				},
			},
		})

		-- ============================================================================
		-- ts_ls Deduplication
		-- Prevents multiple TypeScript language server instances from starting.
		-- ============================================================================
		local pending_ts_ls = {}

		vim.lsp.start = (function()
			local orig_lsp_start = vim.lsp.start
			return function(config, opts)
				local server_name = config and (config.name or config.cmd and config.cmd[1]) or nil

				if server_name ~= "ts_ls" and server_name ~= "typescript-language-server" then
					return orig_lsp_start(config, opts)
				end

				local bufnr = opts and opts.bufnr
				local bufkey = tostring(bufnr or "nil")

				if pending_ts_ls[bufkey] then
					return
				end

				if bufnr then
					for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "ts_ls" })) do
						return client.id
					end
				end

				pending_ts_ls[bufkey] = true
				local id = orig_lsp_start(config, opts)
				pending_ts_ls[bufkey] = nil

				return id
			end
		end)()

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("ts_ls_dedupe", { clear = false }),
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client and client.name == "ts_ls" then
					pending_ts_ls[tostring(args.buf)] = nil
				end
			end,
		})

		-- ============================================================================
		-- LSP Configuration
		-- ============================================================================

		local on_attach = function(client, bufnr)
			vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover documentation" })

			if client.supports_method("textDocument/inlayHint") then
				vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
			end
		end

		local enabled_servers = {}

		for server, server_config in pairs(tools.servers) do
			local base_config = vim.lsp.config[server]
			if base_config and base_config.name then
				local cfg = vim.tbl_deep_extend("force", {}, server_config)
				cfg.mason = nil
				cfg.on_attach = on_attach
				vim.lsp.config[server] = vim.tbl_deep_extend("force", base_config, cfg)
			end

			if server_config.mason ~= false then
				table.insert(enabled_servers, server)
			elseif base_config and base_config.cmd and base_config.cmd[1] and vim.fn.executable(base_config.cmd[1]) == 1 then
				table.insert(enabled_servers, server)
			end
		end

		vim.lsp.enable(enabled_servers)
	end,
}
