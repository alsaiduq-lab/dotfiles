return {
	"mrjones2014/legendary.nvim",
	cmd = "Legendary",
	keys = {
		{ "<leader>l", "<cmd>Legendary<cr>", desc = "Open Legendary" },
	},
	config = function()
		require("legendary").setup({
			which_key = {
				auto_register = true,
				mappings = {
					["<leader>l"] = { name = "+legendary" },
				},
			},
			keymaps = {
				{ "<leader>l", "<cmd>Legendary<cr>", description = "Open Legendary" },
			},
		})
	end,
}
