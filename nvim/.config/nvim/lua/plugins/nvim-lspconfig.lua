return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"saghen/blink.cmp",
	},
	config = function()
		local tools = require("config.lsp.tools")

		-- ============================================================================
		-- ts_ls Deduplication
		-- Prevents multiple TypeScript language server instances from starting.
		-- Tracks pending starts to avoid duplicates.
		-- ============================================================================
		-- Maps bufnr -> true while LSP start is pending
		local pending_ts_ls = {}

		vim.lsp.start = (function()
			-- Capture original before reassignment
			local orig_lsp_start = vim.lsp.start
			return function(config, opts)
				-- Extract server name from config
				local server_name = config and (config.name or config.cmd and config.cmd[1]) or nil

				-- Pass through non-TypeScript servers
				if server_name ~= "ts_ls" and server_name ~= "typescript-language-server" then
					return orig_lsp_start(config, opts)
				end

				local bufnr = opts and opts.bufnr
				local bufkey = tostring(bufnr or "nil")

				-- Skip if ts_ls is already pending for this buffer
				if pending_ts_ls[bufkey] then
					return
				end

				-- Check if ts_ls is already running for this buffer
				if bufnr then
					for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "ts_ls" })) do
						return client.id
					end
				end

				-- Mark as pending while starting
				pending_ts_ls[bufkey] = true
				local id = orig_lsp_start(config, opts)
				pending_ts_ls[bufkey] = nil

				return id
			end
		end)()

		-- Clear pending state when LSP actually attaches
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
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })

			-- Enable inlay hints if supported
			if client.supports_method("textDocument/inlayHint") then
				vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
			end
		end

		-- Configure each server from tools.servers
		for server, server_config in pairs(tools.servers) do
			local base_config = vim.lsp.config[server]
			if base_config and base_config.name then
				vim.lsp.config[server] = vim.tbl_deep_extend("force", base_config, {
					on_attach = on_attach,
					settings = server_config.settings,
					filetypes = server_config.filetypes,
				})
			end
		end

		-- Enable all configured servers
		vim.lsp.enable(vim.tbl_keys(tools.servers))
	end,
}
