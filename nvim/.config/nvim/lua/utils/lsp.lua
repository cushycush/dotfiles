local M = {}

M.on_attach = function(client, bufnr)
	local keymap = vim.keymap.set
	local opts = {
		noremap = true, -- prevent non-recursive mapping
		silent = true, -- don't print the command to the cli
		buffer = bufnr, -- restrict the keymap to the local buffer number
	}

	-- native neovim keymaps
	keymap("n", "<leader>gD", "<cmd>lua vim.lsp.buf.definition()<cr>", opts) -- go to definition
	keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts) -- code actions
	keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>", opts) -- rename symbol
	keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", opts) -- previous diagnostics
	keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", opts) -- next diagnostics
	keymap("n", "<leader>K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts) -- hover docs

	-- Order Imports (if supported by lsp)
	if client.supports_method("textDocument/codeAction") then
		keymap("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = {
					only = { "source.organizeImports" },
					diagnostics = {},
				},
				apply = true,
				bufnr = bufnr,
			})
			-- Format After Changing Import Order
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50)
		end, opts)
	end
end

return M
