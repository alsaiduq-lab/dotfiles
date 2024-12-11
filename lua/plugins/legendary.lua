return {
	"mrjones2014/legendary.nvim",
	cmd = "Legendary",
	keys = {
		{
			"<leader>le",
			function()
				require("legendary").show()
			end,
			desc = "Open Legendary Commands",
		},
	},
	config = function()
		filters = require("legendary.filters")
		local legendary = require("legendary")

		legendary.setup({
			which_key = {
				auto_register = true,
				mappings = {
					["<leader>le"] = { name = "+legendary-commands" },
				},
			},
			keymaps = {
				{
					"<leader>le",
					function()
						legendary.show()
					end,
					description = "Open Legendary Commands",
				},
				{
					"<leader>lek",
					function()
						legendary.find({ filters = filters.keymaps() })
					end,
					description = "View Keymaps",
				},
				{
					"<leader>lec",
					function()
						legendary.find({ filters = filters.commands() })
					end,
					description = "View Commands",
				},
				{
					"<leader>lef",
					function()
						legendary.find({ filters = filters.funcs() })
					end,
					description = "View Functions",
				},
				{
					"<leader>lea",
					function()
						legendary.find({ filters = filters.autocmds() })
					end,
					description = "View Autocmds",
				},
			},
			commands = {
				{
					":LegendaryVisualMode",
					function()
						legendary.find({ filters = filters.mode("v") })
					end,
					description = "Show commands for visual mode",
				},
			},
			sort = {
				frecency = true,
				prioritize = {
					["<leader>"] = 1,
				},
			},
			include_builtin = true,
			include_legendary_cmds = true,
			extensions = {
				which_key = {
					auto_register = true,
				},
			},
			select_prompt = " Legendary ",
			formatter = require("legendary.ui.format").default_format,
		})
	end,
}
