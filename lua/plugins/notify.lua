return {
	"rcarriga/nvim-notify",
	event = "VeryLazy",
	config = function()
		local notify = require("notify")
		notify.setup({
			background_colour = "#000000",
			timeout = 3000,
			max_width = 50,
			render = "wrapped-default",
			stages = "fade_in_slide_out",
			on_open = function(win)
				vim.api.nvim_win_set_option(win, "wrap", true)
			end,
		})

		vim.notify = notify

		vim.cmd([[
      highlight NotifyERRORBorder guifg=#8A1F1F
      highlight NotifyWARNBorder guifg=#79491D
      highlight NotifyINFOBorder guifg=#4F6752
      highlight NotifyDEBUGBorder guifg=#8B8B8B
      highlight NotifyTRACEBorder guifg=#4F3552
      highlight NotifyERRORIcon guifg=#F70067
      highlight NotifyWARNIcon guifg=#F79000
      highlight NotifyINFOIcon guifg=#A9FF68
      highlight NotifyDEBUGIcon guifg=#8B8B8B
      highlight NotifyTRACEIcon guifg=#D484FF
      highlight NotifyERRORTitle guifg=#F70067
      highlight NotifyWARNTitle guifg=#F79000
      highlight NotifyINFOTitle guifg=#A9FF68
      highlight NotifyDEBUGTitle guifg=#8B8B8B
      highlight NotifyTRACETitle guifg=#D484FF
      highlight link NotifyERRORBody Normal
      highlight link NotifyWARNBody Normal
      highlight link NotifyINFOBody Normal
      highlight link NotifyDEBUGBody Normal
      highlight link NotifyTRACEBody Normal
    ]])

		local function demo_notify()
			local plugin = "Sheeeesh Plugin"
			notify("bruh moment fr fr.\nEverything's bussin't! 💀", "error", {
				title = plugin,
				on_open = function()
					notify("No cap, trying to fix this rn fam", vim.log.levels.WARN, {
						title = plugin,
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
								on_close = function()
									notify("ez clap, fixed fr fr", nil, { title = plugin })
									notify("Error code: yeet_0x0395AF", 1, { title = plugin })
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
