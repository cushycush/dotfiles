return {
	"mfussenegger/nvim-lint",
	enabled = false,
	config = function()
		require("lint").linters_by_ft = require("config.lsp.tools").linters

    vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
      callback = function()
        require("lint").try_lint()
      end,
    })
	end,
}
