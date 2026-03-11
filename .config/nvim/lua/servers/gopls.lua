--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
--- @return nil
return function(capabilities)
	vim.lsp.config("gopls", {
		capabilities = capabilities,
		filetypes = { "go" },
	})
end
