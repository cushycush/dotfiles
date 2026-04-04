-- ================================================================================================
-- TITLE : Whichkey.nvim
-- ABOUT : Whichkey helps you remember keymaps
-- ================================================================================================

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {},
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer local keymaps (which-key)",
    },
  },
}
