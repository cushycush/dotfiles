return function(lspconfig, on_attach, capabilities)
	lspconfig.clangd.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		cmd = {
			"clangd",
			"--offset-encoding=utf-16",
		},
		filetypes = { "c", "cpp" },
	})
end
