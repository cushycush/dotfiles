-- ================================================================================================
-- TITLE : treesitter.nvim
-- ABOUT : treesitter configurations and abstraction layer for neovim
-- ================================================================================================

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  lazy = false,
  config = function()
    require("nvim-treesitter.config").setup({
      -- language parsers that MUST be installed
      ensure_installed = {
        "lua",
        "python",
        "bash",
        "typescript",
        "javascript",
        "html",
        "css",
        "json",
        "yaml",
        "go",
        "markdown",
        "dockerfile",
        "markdown_inline",
        "c",
        "cpp",
      },
      auto_install = true,
      sync_install = false,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<cr>",
          node_incremental = "<cr>",
          scope_incremental = "<tab>",
          node_decremental = "<s-tab>",
        },
      },
    })
  end,
}
