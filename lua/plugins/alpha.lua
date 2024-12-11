_G.vim = vim

return {
	{
		"3rd/image.nvim",
		enabled = function()
			return vim.fn.has("win32") == 0
		end,
		opts = {
			backend = "kitty",
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
				},
			},
			max_width_window_percentage = 50,
			max_height_window_percentage = 50,
		},
		build = function()
			require("image").setup()
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"m00qek/baleia.nvim",
				tag = "v1.3.0",
			},
		},
	},
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts = function()
			local dashboard = require("alpha.themes.dashboard")
			require("alpha.term")

			local logo = {
				[[                                                    ]],
				[[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
				[[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
				[[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
				[[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
				[[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
				[[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
				[[                                                    ]],
			}

			local function show_dashboard_image()
				local image_path = vim.fn.expand("~/fastfetching/current_anime_girl")

				if vim.fn.filereadable(image_path) == 1 and vim.fn.has("win32") == 0 then
					vim.defer_fn(function()
						local image = require("image").from_file(image_path, {
							window = 0,
							with_virtual_padding = true,
							x = vim.fn.winwidth(0) - 40,
							y = 3,
							width = 30,
							height = 15,
						})
						image:render()
					end, 100)
				end
			end

			dashboard.section.buttons.val = {
				dashboard.button("f", " " .. "Find files", ":Telescope find_files <CR>"),
			}

			for _, button in ipairs(dashboard.section.buttons.val) do
				button.opts.hl = "AlphaButtons"
				button.opts.hl_shortcut = "AlphaShortcut"
			end

			dashboard.section.header.val = logo
			dashboard.section.header.opts.hl = "Function"
			dashboard.section.buttons.opts.hl = "Identifier"
			dashboard.section.footer.opts.hl = "Function"
			dashboard.opts.layout[1].val = 4

			return dashboard
		end,

		config = function(_, dashboard)
			if vim.o.filetype == "lazy" then
				vim.cmd.close()
				vim.api.nvim_create_autocmd("User", {
					pattern = "AlphaReady",
					callback = function()
						require("lazy").show()
					end,
				})
			end

			require("alpha").setup(dashboard.opts)

			vim.api.nvim_create_autocmd("User", {
				pattern = "AlphaReady",
				callback = function()
					pcall(require("alpha").show_dashboard_image)
				end,
			})

			vim.api.nvim_create_autocmd("User", {
				pattern = "LazyVimStarted",
				callback = function()
					local v = vim.version()
					local dev = v.prerelease == "dev" and "-dev+" .. v.build or ""
					local version = v.major .. "." .. v.minor .. "." .. v.patch .. dev
					local stats = require("lazy").stats()
					local plugins_count = stats.loaded .. "/" .. stats.count
					local ms = math.floor(stats.startuptime + 0.5)
					local time = vim.fn.strftime("%H:%M:%S")
					local date = vim.fn.strftime("%d.%m.%Y")
					local line1 = " " .. plugins_count .. " plugins loaded in " .. ms .. "ms"
					local line2 = "󰃭 " .. date .. "  " .. time
					local line3 = " " .. version

					local line1_width = vim.fn.strdisplaywidth(line1)
					local line2Padded = string.rep(" ", (line1_width - vim.fn.strdisplaywidth(line2)) / 2) .. line2
					local line3Padded = string.rep(" ", (line1_width - vim.fn.strdisplaywidth(line3)) / 2) .. line3

					dashboard.section.footer.val = {
						line1,
						line2Padded,
						line3Padded,
					}
					pcall(vim.cmd.AlphaRedraw)
				end,
			})
		end,
	},
}
