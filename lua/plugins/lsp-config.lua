_G.vim = vim

return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "clangd", "cmake", "cssls", "html", "pyright", "gopls" },
			})
		end
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason-lspconfig.nvim" },
		config = function()
			local lspconfig = require("lspconfig")

			-- Example server configurations
			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							workspace = { library = vim.api.nvim_get_runtime_file("", true) },
						},
					},
				},
				clangd = {},
				cmake = {},
				cssls = {},
				html = {},
				pyright = {},
				gopls = {},
			}

			for server, config in pairs(servers) do
				lspconfig[server].setup(config)
			end
			vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Actions" })
		end
	},
	{
		"nvimdev/lspsaga.nvim",
		event = "BufRead",
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			require("lspsaga").setup({
				ui = {
					border = "rounded",
				},
				lightbulb = {
					enable = true,
					sign = true,
				},
				code_action = {
					show_server_name = true,
				},
			})
		end
	},
}

