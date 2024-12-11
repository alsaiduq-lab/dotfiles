return {
	"linux-cultist/venv-selector.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
		"mfussenegger/nvim-dap",
		"mfussenegger/nvim-dap-python",
		{ "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
	},
	lazy = false,
	branch = "regexp",
	config = function()
		require("venv-selector").setup({
			name = {
				"venv",
				".venv",
				"env",
				".env",
			},
			search_from = "root",
			search_venv_managers = true,
			search_workspace = true,
			parents = 2,
			enable_debug_output = false,
			stay_on_this_version = true,
		})
	end,
	keys = {
		{ ",v", "<cmd>VenvSelect<cr>" },
	},
}
