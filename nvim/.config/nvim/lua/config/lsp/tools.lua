local M = {}

M.servers = {
	lua_ls = {
		settings = {
			Lua = {
				format = {
					enable = false,
				},
			},
		},
	},
	pyright = {},
	gopls = {},
	bashls = {},
	tailwindcss = {
		filetypes = {
			"css",
			"html",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"vue",
			"svelte",
		},
	},
	jsonls = {},
	dockerls = {
		filetypes = {
			"dockerfile",
		},
	},
	clangd = {},
	emmet_ls = {
		filetypes = {
			"css",
			"html",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"vue",
			"svelte",
		},
	},
	ts_ls = {},
	yamlls = {},
}

M.formatters = {
	c = { "clang-format" },
	cpp = { "clang-format" },
	css = { "prettierd" },
	dockerfile = { "prettierd" },
	go = { "gofumpt" },
	html = { "prettierd" },
	javascript = { "prettierd" },
	javascriptreact = { "prettierd" },
	json = { "fixjson" },
	jsonc = { "fixjson" },
	lua = { "stylua" },
	markdown = { "prettierd" },
	python = { "black" },
	sh = { "shfmt" },
	svelte = { "prettierd" },
	typescript = { "prettierd" },
	typescriptreact = { "prettierd" },
	vue = { "prettierd" },
}

M.linters = {
	c = { "cpplint" },
	cpp = { "cpplint" },
	dockerfile = { "hadolint" },
	go = {},
	javascript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	json = { "eslint_d" },
	jsonc = { "eslint_d" },
	lua = { "luacheck" },
	python = { "flake8" },
	sh = { "shellcheck" },
	svelte = { "eslint_d" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	vue = { "eslint_d" },
}

M.get_all_binaries = function()
	local all = {}

	for server, _ in pairs(M.servers) do
		table.insert(all, server)
	end

	for _, f in pairs(M.formatters) do
		for _, name in ipairs(f) do
			table.insert(all, name)
		end
	end

	for _, l in pairs(M.linters) do
		for _, name in ipairs(l) do
			table.insert(all, name)
		end
	end

	return all
end

return M
