_G.vim = vim
return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-web-devicons", "SmiteshP/nvim-navic" },
	config = function()
		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "catppuccin",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = { "dashboard", "neo-tree", "toggleterm", "alpha" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = {
					{ "filename", path = 1 },
					{
						function()
							return "" -- Path-like icon
						end,
						color = { fg = "#89B4FA", bg = "#CBA6F7" }, -- Adjust colors to match your theme
						padding = { left = 1, right = 1 },
					},
					{
						"navic",
						cond = function()
							return require("nvim-navic").is_available()
						end,
					},
				},
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			extensions = { "neo-tree", "toggleterm" },
		})
	end,
}
