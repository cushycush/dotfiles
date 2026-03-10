return function(lspconfig, on_attach, capabilities)
	lspconfig.tailwindcss.setup({
		on_attach = on_attach,
		capabilities = capabilities,
		filetypes = { "javascriptreact", "typescriptreact", "typescript", "javascript", "vue", "svelte" },
	})
end
