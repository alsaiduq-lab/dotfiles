return {
	"rcarriga/nvim-notify",
	event = "VeryLazy",
	config = function()
		local notify = require("notify")
		notify.setup({
			background_colour = "#1a1b26",
			timeout = 3000,
			max_width = 60,
			render = "wrapped-default",
			stages = "fade",
			on_open = function(win)
				vim.api.nvim_win_set_option(win, "wrap", true)
				vim.api.nvim_win_set_config(win, { border = "rounded" })
			end,
		})

		vim.notify = notify

		vim.cmd([[
      highlight NotifyERRORBorder guifg=#db4b4b guibg=NONE
      highlight NotifyWARNBorder guifg=#e0af68 guibg=NONE
      highlight NotifyINFOBorder guifg=#0db9d7 guibg=NONE
      highlight NotifyDEBUGBorder guifg=#9d7cd8 guibg=NONE
      highlight NotifyTRACEBorder guifg=#bb9af7 guibg=NONE
      highlight NotifyERRORIcon guifg=#ff0055 guibg=NONE
      highlight NotifyWARNIcon guifg=#ffb86c guibg=NONE
      highlight NotifyINFOIcon guifg=#7dcfff guibg=NONE
      highlight NotifyDEBUGIcon guifg=#9d7cd8 guibg=NONE
      highlight NotifyTRACEIcon guifg=#bb9af7 guibg=NONE
      highlight NotifyERRORTitle guifg=#ff0055 guibg=NONE gui=bold
      highlight NotifyWARNTitle guifg=#ffb86c guibg=NONE gui=bold
      highlight NotifyINFOTitle guifg=#7dcfff guibg=NONE gui=bold
      highlight NotifyDEBUGTitle guifg=#9d7cd8 guibg=NONE gui=bold
      highlight NotifyTRACETitle guifg=#bb9af7 guibg=NONE gui=bold
      highlight NotifyERRORBody guibg=NONE guifg=#c0caf5
      highlight NotifyWARNBody guibg=NONE guifg=#c0caf5
      highlight NotifyINFOBody guibg=NONE guifg=#c0caf5
      highlight NotifyDEBUGBody guibg=NONE guifg=#c0caf5
      highlight NotifyTRACEBody guibg=NONE guifg=#c0caf5
]])

		local function demo_notify()
			local plugin = "Sheeeesh Plugin"
			notify("bruh moment fr fr.\nEverything's bussin't! 💀", "error", {
				title = plugin,
				animate = true,
				on_open = function()
					notify("No cap, trying to fix this rn fam", vim.log.levels.WARN, {
						title = plugin,
						icon = "🔧",
					})

					local timer = vim.loop.new_timer()
					timer:start(2000, 0, function()
						notify(
							{
								"Vibing with the fix rn",
								"On god, just wait a sec...",
							},
							"info",
							{
								title = plugin,
								timeout = 3000,
								icon = "⚡",
								on_close = function()
									notify("ez clap, fixed fr fr", nil, { title = plugin, icon = "✨" })
									notify("Error code: yeet_0x0395AF", 1, { title = plugin, icon = "📝" })
								end,
							}
						)
					end)
				end,
			})
		end

		local function markdown_notify()
			local text = "# No cap fr fr\nThis markdown be bussin"
			notify(text, "info", {
				title = "Sheeeesh Plugin",
				icon = "📘",
				on_open = function(win)
					local buf = vim.api.nvim_win_get_buf(win)
					vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
				end,
			})
		end

		require("telescope").load_extension("notify")
	end,
	dependencies = {
		"nvim-telescope/telescope.nvim",
	},
}
