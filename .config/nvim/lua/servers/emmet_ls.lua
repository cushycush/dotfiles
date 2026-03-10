return function(lspconfig, on_attach, capabilities)
	lspconfig.emmet_ls.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		filetypes = {
			"typescript",
			"javascript",
			"typescriptreact",
			"javascriptreact",
			"css",
			"sass",
			"scss",
			"svelte",
			"vue",
		},
	})
end
