return function(lspconfig, on_attach, capabilities)
	lspconfig.pyright.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		filetypes = { "python" },
		settings = {
			pyright = {
				analysis = {
					autoSearchPaths = true,
					diagnosticMode = "workspace",
					useLibraryCodeForTypes = true,
					autoImportCompletion = true,
					disableOrganizeImports = false,
				},
			},
		},
	})
end
