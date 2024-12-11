---@diagnostic disable: undefined-field
return {
	"folke/persistence.nvim",
	event = "BufReadPre",
	opts = {
		dir = vim.fn.stdpath("data") .. "/sessions/",
		options = { "buffers", "curdir", "tabpages", "winsize" },
		autosave = {
			enabled = true,
			interval = 60,
			maxfiles = 5,
		},
		cleanup = {
			enabled = true,
			days = 7,
		},
	},
	config = function(_, opts)
		require("persistence").setup(opts)

		local cleanup_timer = vim.loop.new_timer()
		cleanup_timer:start(0, 24 * 60 * 60 * 1000, function()
			vim.schedule(function()
				require("persistence").cleanup()
			end)
		end)

		local autosave_timer = vim.loop.new_timer()
		autosave_timer:start(0, opts.autosave.interval * 1000, function()
			if opts.autosave.enabled then
				vim.schedule(function()
					require("persistence").save()
				end)
			end
		end)
	end,
	keys = {
		{
			"<leader>sl",
			function()
				require("persistence").load()
			end,
			desc = "Restore Session",
		},
		{
			"<leader>ss",
			function()
				require("persistence").save()
			end,
			desc = "Save Session",
		},
		{
			"<leader>sd",
			function()
				require("persistence").stop()
			end,
			desc = "Stop Persistence",
		},
	},
}
