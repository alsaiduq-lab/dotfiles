return {
	"akinsho/bufferline.nvim",
	dependencies = "nvim-tree/nvim-web-devicons",
	event = "VeryLazy",

	config = function()
		require("bufferline").setup({
			options = {
				mode = "buffers",
				separator_style = "thin",
				always_show_bufferline = false,
				show_buffer_close_icons = true,
				show_close_icon = false,
				color_icons = true,
			},
		})
	end,
}
