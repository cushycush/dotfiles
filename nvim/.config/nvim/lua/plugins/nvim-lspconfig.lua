return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"saghen/blink.cmp",
	},
	config = function()
		local tools = require("config.lsp.tools")
		local blink = require("blink.cmp")

		-- In-memory ts_ls dedupe state.
		local pending_by_key = {}
		local pending_by_buf = {}

		if not vim.g._agent_lsp_wrapped then
			vim.g._agent_lsp_wrapped = true

			local orig_start = vim.lsp.start
			vim.lsp.start = function(config, opts)
				local name = config and (config.name or config.cmd and config.cmd[1]) or nil
				if name == "ts_ls" or name == "typescript-language-server" then
					local bufnr = opts and opts.bufnr or nil
					local bufname = bufnr and vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_get_name(bufnr) or nil
					local root_dir = config and config.root_dir or nil
					if type(root_dir) == "function" then
						local ok_rd, rd = pcall(root_dir, bufname)
						if ok_rd then
							root_dir = rd
						end
					end

					local key = tostring(bufnr or "nil") .. "|" .. tostring(root_dir or "nil")
					local bufkey = tostring(bufnr or "nil")

					if pending_by_key[key] then
						return pending_by_key[key]
					end

					if bufnr and pending_by_buf[bufkey] then
						return pending_by_buf[bufkey]
					end

					if bufnr then
						for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "ts_ls" })) do
							if root_dir and c.config and c.config.root_dir == root_dir then
								return c.id
							end
						end
					end

					pending_by_key[key] = "pending"
					if bufnr then
						pending_by_buf[bufkey] = "pending"
					end
					local id = orig_start(config, opts)
					pending_by_key[key] = id or "started"
					if bufnr then
						pending_by_buf[bufkey] = id or "started"
					end
					return id
				end
				return orig_start(config, opts)
			end
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client and client.name == "ts_ls" then
					local key = tostring(args.buf) .. "|" .. tostring(client.config and client.config.root_dir or "nil")
					pending_by_key[key] = nil
					pending_by_buf[tostring(args.buf)] = nil
				end
			end,
		})

		local on_attach = function(client, bufnr)
			local opts = { buffer = bufnr }
			vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

			if client.supports_method("textDocument/inlayHint") then
				vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
			end
		end

		-- Use vim.lsp.config for Neovim 0.11+
		for server, server_config in pairs(tools.servers) do
			if vim.lsp.config[server] and vim.lsp.config[server].name then
				local base = vim.lsp.config[server] or {}
				vim.lsp.config[server] = vim.tbl_deep_extend("force", base, {
					on_attach = on_attach,
					settings = server_config.settings,
					filetypes = server_config.filetypes,
				})
			end
		end

		vim.lsp.enable(vim.tbl_keys(tools.servers))

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client and client.name == "stylua" then
					vim.lsp.stop_client(args.data.client_id)
				end
			end,
		})
	end,
}
