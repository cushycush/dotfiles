-- ================================================================================================
-- TITLE : NeoVim keymaps
-- ABOUT : sets some quality of life keymaps
-- ================================================================================================

-- Center Screen When Jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Buffer Navigation
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

-- Better Window Navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Splitting and Resizing
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<cr>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Increase window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Better Indenting in Visual Mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Better J Behavior
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Quick Config Editing
vim.keymap.set("n", "<leader>rc", "<cmd>e ~/.config/init.lua<cr>", { desc = "Edit config" })

-- File Explorer
vim.keymap.set("n", "<leader>m", "<cmd>NvimTreeFocus<cr>", { desc = "Focus file explorer"})
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer"})

-- Delete and Change Without Yanking
vim.keymap.set({'n', 'v'}, '<leader>d', '"_d')
vim.keymap.set({'n', 'v'}, '<leader>D', '"_D')
vim.keymap.set({'n', 'v'}, 'c', '"_c')
vim.keymap.set({'n', 'v'}, 'C', '"_C')
vim.keymap.set({'n', 'v'}, 'x', '"_x')
vim.keymap.set({'n', 'v'}, 'X', '"_X')

-- Save and Quit
vim.keymap.set("n", "<leader>q", "<cmd>wqa!", { desc = "Save and quit" })

-- Copy File Path
vim.keymap.set("n", "<leader>pa", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    print("file:", path)
  end, { desc = "Copy full file path" }
)

-- Clear Highlights
vim.keymap.set("n", "<esc>", "<cmd>noh<cr>")
