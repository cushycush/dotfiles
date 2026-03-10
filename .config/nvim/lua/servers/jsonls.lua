return function(lspconfig, on_attach, capabilities)
	lspconfig.jsonls.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		filetypes = { "json", "jsonc" },
	})
end
