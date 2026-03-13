--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
--- @return nil
return function(capabilities)
	vim.lsp.config("emmet_ls", {
		capabilities = capabilities,
		filetypes = {
			"css",
			"javascript",
			"javascriptreact",
			"sass",
			"scss",
			"svelte",
			"typescript",
			"typescriptreact",
			"vue",
		},
	})
end
