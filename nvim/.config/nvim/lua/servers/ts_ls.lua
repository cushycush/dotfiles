--- @param capabilities table LSP client capabilities (typically from nvim-cmp or similar)
--- @return nil
return function(capabilities)
	vim.lsp.config("ts_ls", {
		capabilities = capabilities,
		filetypes = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
		settings = {
			typescript = {
				indentStyle = "space",
				indentSize = 2,
			},
		},
	})
end
