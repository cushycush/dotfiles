return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
  keys = {
    {
      "n", "<cmd>CodeCompanionChat Toggle<cr>", "<leader>ac", { desc = "Code Companion chat toggle" }
    },
  },
	opts = {},
	config = function(_, opts)
		require("codecompanion").setup(opts)

		vim.keymap.set("n", "<cmd>CodeCompanionChat Toggle<cr>", "<leader>ac", { desc = "Code Companion chat toggle" })
	end,
}
