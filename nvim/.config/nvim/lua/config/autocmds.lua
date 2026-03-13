-- ================================================================================================
-- TITLE : NeoVim Auto-commands
-- ABOUT : automatically run code on defined events (e.g. save, yank)
-- ================================================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Restore Last Cursor Position When Reopening a File
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  desc = "Restore last cursor position",
  callback = function()
    if vim.o.diff then
      return
    end

    local last_pos = vim.api.nvim_buf_get_mark(0, '"')
    local last_line = vim.api.nvim_buf_line_count(0)

    local row = last_pos[1]
    if row < 1 or row > last_line then
      return
    end

    pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
  end,
})

-- Highlight the Yanked Text for 200ms
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Wrap, Linebreak and Spellcheck on Markdown and Text Files
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
  end,
})

-- Format on Save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  callback = function()
    local efm = vim.lsp.get_clients({ name = "efm" })
    if vim.tbl_isempty(efm) then
      return
    end
    vim.lsp.buf.format({ name = "efm", async = true })
  end
})
