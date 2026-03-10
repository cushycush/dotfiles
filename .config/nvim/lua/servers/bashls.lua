return function(lspconfig, on_attach, capabilities)
	lspconfig.bashls.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		filetypes = { "sh" },
	})
end
