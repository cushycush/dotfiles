return function(lspconfig, on_attach, capabilities)
	lspconfig.gopls.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		filetypes = { "go" },
	})
end
