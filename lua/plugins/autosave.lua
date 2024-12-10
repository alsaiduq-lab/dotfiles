return {
	"Pocco81/auto-save.nvim",
	event = { "InsertLeave", "TextChanged", "FocusLost", "BufLeave" },
	config = function()
		require("auto-save").setup({
			enabled = true,
			trigger_events = {
				"InsertLeave",
				"FocusLost",
				"BufLeave",
			},
			execution_message = {
				message = function()
					local modified = vim.bo.modified
					if modified then
						return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
					end
					return ""
				end,
				dim = 0.18,
				cleaning_interval = 1250,
			},
			condition = function(buf)
				local utils = require("auto-save.utils.data")

				if
					utils.not_in(vim.bo.filetype, {
						"neo-tree",
						"TelescopePrompt",
						"lazy",
						"terminal",
						"prompt",
						"noice",
						"notify",
						"mason",
					})
				then
					local pumvisible = vim.fn.pumvisible() == 1
					local completing = vim.fn.complete_info().mode ~= nil

					if not pumvisible and not completing then
						return true
					end
				end
				return false
			end,
			write_all_buffers = false,
			debounce_delay = 500,
			throttle_duration = 2000,
		})
	end,
}
