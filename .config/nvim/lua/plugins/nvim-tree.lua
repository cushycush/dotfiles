-- ================================================================================================
-- TITLE : nvim-tree.nvim
-- ABOUT : file tree
-- ================================================================================================

return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  config = function()
    -- Remove background color from the NvimTree window
    vim.cmd([[hi NvimTreeNormal guibg=NONE ctermbg=NONE]])

    require("nvim-tree").setup({
      filters = {
        dotfiles = false, -- Show hidden files
      },
      view = {
        adaptive_size = true,
      },
    })
  end,
}

