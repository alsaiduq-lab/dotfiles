_G.vim = vim
return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			local navic = require("nvim-navic")
			vim.keymap.set("n", "<C-p>", function()
				builtin.find_files({ icons = navic.get_icon() })
			end, {})
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
	},
}
