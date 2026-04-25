return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    exclude = {
      filetypes = {
        "help",
        "dashboard",
        "Trouble",
      },
      buftypes = {
        "terminal",
        "nofile",
      },
    },
    indent = {
      char = "▏",
    },
    scope = {
      enabled = true,
      char = "▏",
      show_start = true,
      show_end = false,
      show_exact_scope = false,
    },
  },
}
