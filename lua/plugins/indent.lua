return {
	"lukas-reineke/indent-blankline.nvim",
	event = "BufRead",
	config = function()
		local hooks = require("ibl.hooks")
		hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
			vim.api.nvim_set_hl(0, "IblIndent", { fg = "#404040" })
		end)
		require("ibl").setup({
			indent = {
				char = "┊",
			},
			scope = {
				enabled = true,
				show_start = true,
			},
		})
	end,
}
