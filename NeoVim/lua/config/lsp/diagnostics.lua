local U = require("utils.chars")

local M = {}

M.setup = function()
	vim.diagnostic.config({
		virtual_lines = false,
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = U.diagnostic_signs.Error,
				[vim.diagnostic.severity.WARN] = U.diagnostic_signs.Warn,
				[vim.diagnostic.severity.INFO] = U.diagnostic_signs.Info,
				[vim.diagnostic.severity.HINT] = U.diagnostic_signs.Hint,
			},
		},
	})
end

return M
