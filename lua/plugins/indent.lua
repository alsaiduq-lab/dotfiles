return {
	"lukas-reineke/indent-blankline.nvim",
	event = "BufRead",
	config = function()
		local hooks = require("ibl.hooks")
		hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
			vim.api.nvim_set_hl(0, "IblIndent", { fg = "#444444" })
			vim.api.nvim_set_hl(0, "IblScope", { fg = "#666666" })
		end)
		require("ibl").setup({
			indent = {
				char = "┊",
				highlight = "IblIndent",
			},
			scope = {
				enabled = true,
				show_start = true,
				show_end = true,
				highlight = "IblScope",
				priority = 500,
			},
			exclude = {
				filetypes = { "help", "dashboard", "lazy", "mason", "alpha" },
				buftypes = { "terminal", "nofile", "quickfix", "prompt" },
			},
			whitespace = {
				remove_blankline_trail = true,
			},
		})
	end,
}
