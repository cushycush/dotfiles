-- ================================================================================================
-- TITLE : NeoVim options
-- ABOUT : basic settings native to neovim
-- ================================================================================================

local U = require("utils.neovim")
local C = require("utils.chars")

-- Basic Settings
vim.opt.number = true -- line numbers
vim.opt.relativenumber = true -- relative line numbers
vim.opt.cursorline = true -- highlight current line
vim.opt.scrolloff = 999 -- keep cursor in the middle of the screen when scrolling
vim.opt.sidescrolloff = 8 -- keep 8 columns left/right of cursor
vim.opt.wrap = false -- don't wrap lines
vim.opt.cmdheight = 0 -- command line only appears when using it
vim.opt.spelllang = { "en" } -- set language for spellchecking
vim.opt.inccommand = "split" -- show previews in a split window

-- Tabbing / Indentation
vim.opt.tabstop = 2 -- tab width
vim.opt.shiftwidth = 2 -- indent width
vim.opt.softtabstop = 2 -- soft tab stop
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.smartindent = true -- smart auto-indenting
vim.opt.autoindent = true -- copy indent from current line
vim.opt.grepprg = "rg --vimgrep" -- use ripgrep if available
vim.opt.grepformat = "%f:%l:%c:%m" -- filename, line number, column, content

-- Search Settings
vim.opt.ignorecase = true -- case-insensitive search
vim.opt.smartcase = true -- case-sensitive if uppercase in search
vim.opt.hlsearch = true -- highlight search results
vim.opt.incsearch = true -- show matches as you type

-- Visual Settings
vim.opt.termguicolors = true -- enable 24-bit colors
vim.opt.signcolumn = "yes:2" -- always show sign-column with fixed width of 1
vim.opt.colorcolumn = "100" -- show sign column at 100 characters
vim.opt.showmatch = true -- highlight matching brackets
vim.opt.matchtime = 2 -- how long to show matching bracket
vim.opt.completeopt = "menuone,noinsert,noselect" -- completion options
vim.opt.showmode = false -- don't show mode in command line
vim.opt.pumheight = 10 -- popup menu height
vim.opt.pumblend = 0 -- popup menu transparency
vim.opt.winblend = 0 -- floating window transparency
vim.opt.conceallevel = 0 -- don't hide markup
vim.opt.concealcursor = "" -- show markup even on cursor line
vim.opt.lazyredraw = false -- redraw while execuring macros (better UX)
vim.opt.redrawtime = 10000 -- timeout for syntax highlighting redraw
vim.opt.maxmempattern = 20000 -- max memory for pattern matching
vim.opt.synmaxcol = 300 -- syntax highlighting column limit
vim.opt.list = true
vim.opt.listchars = { space = "·", tab = " ·", trail = " " }

-- File Handling
vim.opt.backup = false -- don't create backup files
vim.opt.writebackup = false -- don't backup before overwriting
vim.opt.swapfile = false -- don't create swap files
vim.opt.undofile = true -- persistent undo
vim.opt.updatetime = 300 -- time in ms to trigger cursorhold
vim.opt.timeoutlen = 500 -- time in ms to wait for mapped sequence
vim.opt.ttimeoutlen = 0 -- no wait for key code sequences
vim.opt.autoread = true -- auto-reload file if changed outside
vim.opt.autowrite = false -- don't auto-save on some events
vim.opt.diffopt:append("vertical") -- vertical diff splits
vim.opt.diffopt:append("algorithm:patience") -- better diff algorithm
vim.opt.diffopt:append("linematch:60") -- better diff highlighting (smart line matching)

-- Set Undo Directory and Ensure It Exists
local undodir = vim.fn.expand("~/.local/share/nvim/undodir") -- undo directory path
vim.opt.undodir = undodir
if vim.fn.isdirectory(undodir) == 0 then
	vim.fn.mkdir(undodir, "p") -- create if not exists
end

-- Behavior Settings
vim.opt.errorbells = false -- disable error sounds
vim.opt.backspace = "indent,eol,start" -- make backspace behave naturally
vim.opt.autochdir = false -- don't change directory automatically
vim.opt.iskeyword:append("-") -- treat dash as part of a word
vim.opt.path:append("**") -- search into subfolders with `gf`
vim.opt.selection = "inclusive" -- use inclusive selection
vim.opt.virtualedit = "block" -- allow virtual block selection to select individual cells
vim.opt.mouse = "a" -- enable mouse support
vim.opt.clipboard:append("unnamedplus") -- use system clipboard
vim.opt.modifiable = true -- allow editing buffers
vim.opt.encoding = "UTF-8" -- use UTF-8 encoding
vim.opt.wildmenu = true -- enable command-line completion menu
vim.opt.wildmode = "longest:full,full" -- completion mode for command-line
vim.opt.wildignorecase = true -- case-insensitive tab completion in commands

-- Cursor Settings
vim.opt.guicursor = {
	"n-v-c:block", -- normal, visual, command-line
	"i-ci-ve:ver25", -- insert, command-line insert, visual-exclusive
	"r-cr:hor20", -- replace, command-line replace
	"o:hor50", -- operator-pending
	"a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor", -- all modes: blinking & highlight groups
	"sm:block-blinkwait175-blinkoff150-blinkon175", -- showmatch mode
}

-- Folding Settings
vim.opt.foldmethod = "expr" -- use expression for folding
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- use treesitter for folding
vim.opt.foldlevel = 99 -- keep all folds open by default

-- Split Behavior
vim.opt.splitbelow = true -- horizontal splits open below
vim.opt.splitright = true -- vertical splits open to the right

if not U.is_default() then
	vim.opt.fillchars = {
		horiz = C.bottom_thin,
		horizup = C.bottom_thin,
		horizdown = C.right_thick,
		vert = C.right_thick,
		vertleft = C.right_thick,
		vertright = C.right_thick,
		verthoriz = C.right_thick,
	}
else
	vim.opt.fillchars = {
		eob = " ",
		diff = "╱",
		vert = C.right_thick,
		vertleft = C.right_thick,
		vertright = C.right_thick,
		verthoriz = C.right_thick,
		horiz = C.bottom_thin,
		horizup = C.bottom_right_thin,
	}
end
