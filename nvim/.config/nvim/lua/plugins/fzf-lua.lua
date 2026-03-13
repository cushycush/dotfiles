-- ================================================================================================
-- TITLE : fzf-lua.nvim
-- ABOUT : lua-based fzf wrapper and integration
-- ================================================================================================

return {
  "ibhagwan/fzf-lua",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {
      "<leader>ff",
      function()
        require("fzf-lua").files()
      end,
      desc = "FZF files",
    },
    {
      "<leader>fg",
      function()
        require("fzf-lua").live_grep()
      end,
      desc = "FZF live grep",
    },
    {
      "<leader>fb",
      function()
        require("fzf-lua").buffers()
      end,
      desc = "FZF Buffers",
    },
    {
      "<leader>fh",
      function()
        require("fzf-lua").help_tags()
      end,
      desc = "FZF help tags",
    },
    {
      "<leader>fx",
      function()
        require("fzf-lua").diagnostics_document()
      end,
      desc = "FZF diagnostics document",
    },
  },
  opts = {},
}
