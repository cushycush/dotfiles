return function(lspconfig, on_attach, capabilities)
	lspconfig.dockerls.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		filetypes = { "docker" },
	})
end
