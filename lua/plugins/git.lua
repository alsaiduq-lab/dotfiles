return {
	{
		"tpope/vim-fugitive",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
			"tpope/vim-rhubarb",
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
			{
				"iamcco/markdown-preview.nvim",
				build = "cd app && npm install",
				init = function()
					vim.g.mkdp_auto_start = 0
					vim.g.mkdp_auto_close = 1
					vim.g.mkdp_refresh_slow = 0
					vim.g.mkdp_command_for_global = 0
					vim.g.mkdp_browser = ""
					vim.g.mkdp_preview_options = {
						mkit = {},
						katex = {},
						uml = {},
						maid = {},
						disable_sync_scroll = 0,
						sync_scroll_type = "middle",
					}
				end,
				ft = { "markdown" },
			},
		},
		config = function()
			local function create_git_buffer(command, title)
				local bufnr = vim.api.nvim_create_buf(false, true)
				if bufnr == 0 then
					vim.notify("Failed to create buffer", vim.log.levels.ERROR)
					return nil
				end
				vim.api.nvim_buf_set_name(bufnr, title)
				vim.bo[bufnr].buftype = "nofile"
				vim.bo[bufnr].swapfile = false
				vim.bo[bufnr].bufhidden = "wipe"
				vim.bo[bufnr].filetype = "git"
				vim.bo[bufnr].modifiable = true
				local win = vim.api.nvim_get_current_win()
				vim.api.nvim_win_set_buf(win, bufnr)
				local output = vim.fn.systemlist(command)
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
				vim.bo[bufnr].modifiable = false
				vim.api.nvim_create_autocmd("BufWipeout", {
					buffer = bufnr,
					callback = function()
						vim.cmd("silent! %bwipeout!")
					end,
				})
				return bufnr
			end

			local function git_command(command)
				if command == "commit" then
					vim.ui.input({ prompt = "Commit message > " }, function(input)
						if input and input ~= "" then
							vim.fn.system("git add -A")
							local commit_cmd = string.format('git commit -m "%s"', input:gsub('"', '\\"'))
							local result = vim.fn.system(commit_cmd)
							if vim.v.shell_error == 0 then
								vim.notify("Changes committed successfully", vim.log.levels.INFO)
								return true
							else
								vim.notify("Failed to commit: " .. result, vim.log.levels.ERROR)
								return false
							end
						end
						return false
					end)
					return true
				elseif command == "push" then
					local branch = vim.fn.system("git branch --show-current"):gsub("\n", "")
					local result = vim.fn.system("git push origin " .. branch)
					if vim.v.shell_error == 0 then
						vim.notify("Changes pushed to " .. branch, vim.log.levels.INFO)
					else
						vim.notify("Failed to push: " .. result, vim.log.levels.ERROR)
					end
				elseif command == "pull" then
					local result = vim.fn.system("git pull")
					if vim.v.shell_error == 0 then
						vim.notify("Successfully pulled changes", vim.log.levels.INFO)
					else
						vim.notify("Failed to pull: " .. result, vim.log.levels.ERROR)
					end
				elseif command == "cherry-pick" then
					require("telescope.builtin").input_prompt({
						prompt = "Enter commit hash to cherry-pick > ",
						on_complete = function(input)
							if input and input ~= "" then
								local result = vim.fn.system("git cherry-pick " .. input)
								if vim.v.shell_error == 0 then
									vim.notify("Cherry-pick completed successfully", vim.log.levels.INFO)
								else
									vim.notify("Cherry-pick failed: " .. result, vim.log.levels.ERROR)
								end
							end
						end,
					})
				elseif command == "status" then
					create_git_buffer("git status", "Git Status")
				elseif command == "log" then
					create_git_buffer("git log", "Git Log")
					vim.api.nvim_buf_set_keymap(0, "n", "q", ":bd!<CR>", { noremap = true, silent = true })
				elseif command == "blame" then
					local current_file = vim.fn.expand("%:p")
					if current_file == "" then
						vim.notify("No file selected for blame", vim.log.levels.WARN)
						return
					end
					create_git_buffer(
						"git blame " .. vim.fn.shellescape(current_file),
						"Git Blame: " .. vim.fn.expand("%:t")
					)
				else
					vim.cmd("Git " .. command)
				end
			end

			local git_commands = {
				{ key = "<leader>gc", cmd = "commit", desc = "Git Commit" },
				{ key = "<leader>gp", cmd = "push", desc = "Git Push" },
				{ key = "<leader>gpl", cmd = "pull", desc = "Git Pull" },
				{ key = "<leader>gcp", cmd = "cherry-pick", desc = "Git Cherry Pick" },
				{ key = "<leader>gs", cmd = "status", desc = "Git Status" },
				{ key = "<leader>gl", cmd = "log", desc = "Git Log" },
				{ key = "<leader>gbl", cmd = "blame", desc = "Git Blame" },
			}

			for _, command in ipairs(git_commands) do
				vim.keymap.set("n", command.key, function()
					git_command(command.cmd)
				end, { desc = command.desc })
			end

			vim.keymap.set("n", "<leader>gb", function()
				local Menu = require("nui.menu")
				local function create_url_preview(url)
					local system_commands = {
						mac = "open",
						unix = "xdg-open",
						win = "start",
					}
					local sys = vim.fn.has("mac") == 1 and "mac" or vim.fn.has("unix") == 1 and "unix" or "win"
					vim.fn.system(string.format("%s %s", system_commands[sys], url))
				end

				local function execute_git_action(action, callback)
					local Job = require("plenary.job")
					Job:new({
						command = "git",
						args = vim.split(action, "%s+"),
						on_exit = function(j, return_val)
							if return_val == 0 and callback then
								callback(j:result())
							end
						end,
					}):start()
				end

				local menu_items = {
					Menu.item("Browse Current File", {
						action = function()
							vim.cmd("GBrowse")
						end,
					}),
					Menu.item("Copy Current File URL", {
						action = function()
							vim.cmd("GBrowse!")
						end,
					}),
					Menu.item("Browse Repository", {
						action = function()
							execute_git_action("config --get remote.origin.url", function(result)
								local url = result[1]
								if url:match("github.com") then
									url = url:gsub("git@github.com:", "https://github.com/")
									url = url:gsub("%.git$", "")
									create_url_preview(url)
								end
							end)
						end,
					}),
					Menu.item("Browse Issues", {
						action = function()
							vim.cmd("GBrowse issues")
						end,
					}),
					Menu.item("Browse Pull Requests", {
						action = function()
							vim.cmd("GBrowse pulls")
						end,
					}),
					Menu.item("Browse Actions", {
						action = function()
							vim.cmd("GBrowse actions")
						end,
					}),
					Menu.item("Browse Wiki", {
						action = function()
							vim.cmd("GBrowse wiki")
						end,
					}),
				}

				local menu = Menu({
					position = "50%",
					size = {
						width = 60,
					},
					border = {
						style = "rounded",
						text = {
							top = "Git Browsing",
							top_align = "center",
						},
					},
					win_options = {
						winhighlight = "Normal:Normal,FloatBorder:Normal",
					},
				}, {
					lines = menu_items,
					max_width = 20,
					keymap = {
						focus_next = { "j", "<Down>", "<Tab>" },
						focus_prev = { "k", "<Up>", "<S-Tab>" },
						close = { "<Esc>", "<C-c>" },
						submit = { "<CR>", "<Space>" },
					},
					on_submit = function(item)
						item.action()
					end,
				})

				menu:mount()
			end, { desc = "Git Browsing" })
		end,
	},
	{
		"sindrets/diffview.nvim",
		event = "VeryLazy",
		config = function()
			local actions = require("diffview.actions")
			require("diffview").setup({
				enhanced_diff_hl = true,
				signs = {
					fold_closed = "",
					fold_open = "",
					done = "✓",
				},
				view = {
					default = {
						layout = "diff2_horizontal",
					},
				},
				hooks = {
					diff_buf_read = function(bufnr)
						vim.opt_local.wrap = false
						vim.opt_local.list = false
						vim.opt_local.colorcolumn = { 80 }
						vim.opt.fillchars:append({ diff = "╱" })
					end,
					view_opened = function(view)
						local bufnr = vim.api.nvim_get_current_buf()
						if not (bufnr and vim.api.nvim_buf_is_valid(bufnr)) then
							return
						end
						if vim.bo[bufnr].filetype ~= "DiffviewFiles" then
							vim.bo[bufnr].buftype = "nofile"
							vim.bo[bufnr].modifiable = false
							vim.bo[bufnr].readonly = true
							vim.bo[bufnr].filetype = "DiffviewFiles"
							vim.api.nvim_buf_set_name(bufnr, "Git Diff View")
							vim.bo[bufnr].buflisted = false
							vim.opt.signcolumn = "yes"
							vim.opt.foldmethod = "syntax"
							vim.cmd([[
                            sign define DiffAdd text=+ texthl=DiffAdd
                            sign define DiffChange text=~ texthl=DiffChange
                            sign define DiffDelete text=- texthl=DiffDelete
                        ]])
						end

						vim.api.nvim_create_autocmd("VimLeavePre", {
							callback = function()
								vim.cmd("DiffviewClose")
							end,
						})
					end,
					view_closed = function()
						local function close_all_buffers()
							local base_bufs = {
								["DiffviewFileHistory"] = true,
								["DiffviewFiles"] = true,
							}

							for _, buf in ipairs(vim.api.nvim_list_bufs()) do
								if vim.api.nvim_buf_is_valid(buf) then
									local ft = vim.bo[buf].filetype
									if base_bufs[ft] or not ft then
										vim.api.nvim_buf_delete(buf, { force = true })
									end
								end
							end
							vim.cmd("silent! %bwipeout!")
							vim.cmd("clearjumps")
						end

						close_all_buffers()

						if vim.fn.bufexists("#") == 1 then
							vim.cmd("e #")
						end
					end,
					file_open = function(bufnr)
						if not (bufnr and vim.api.nvim_buf_is_valid(bufnr)) then
							return
						end
						if vim.bo[bufnr].filetype ~= "DiffviewFiles" then
							vim.bo[bufnr].buftype = "nofile"
							vim.bo[bufnr].modifiable = false
							vim.bo[bufnr].readonly = true
							vim.bo[bufnr].filetype = "DiffviewFiles"
							vim.bo[bufnr].buflisted = false
							vim.opt.signcolumn = "yes"
							local file_name = vim.fn.expand("%:t")
							if file_name and file_name ~= "" then
								vim.api.nvim_buf_set_name(bufnr, "Git Diff: " .. file_name)
							end
						end
					end,
				},
				keymaps = {
					view = {
						["q"] = actions.close,
						["<tab>"] = actions.select_next_entry,
						["<s-tab>"] = actions.select_prev_entry,
						["gf"] = actions.goto_file_edit,
						["<C-w><C-f>"] = actions.goto_file_split,
						["<C-w>gf"] = actions.goto_file_tab,
						["<leader>e"] = actions.focus_files,
						["<leader>b"] = actions.toggle_files,
						["]c"] = actions.next_conflict,
						["[c"] = actions.prev_conflict,
					},
					file_panel = {
						["q"] = actions.close,
						["j"] = actions.next_entry,
						["<down>"] = actions.next_entry,
						["k"] = actions.prev_entry,
						["<up>"] = actions.prev_entry,
						["<cr>"] = actions.select_entry,
						["o"] = actions.select_entry,
						["R"] = actions.refresh_files,
						["L"] = actions.open_commit_log,
						["X"] = actions.restore_entry,
						["s"] = actions.toggle_stage_entry,
						["S"] = actions.stage_all,
						["U"] = actions.unstage_all,
						["<tab>"] = actions.select_next_entry,
						["<s-tab>"] = actions.select_prev_entry,
					},
				},
			})
			vim.keymap.set("n", "<leader>do", ":DiffviewOpen<CR>", { silent = true, desc = "Git Diff View" })
			vim.keymap.set("n", "<leader>dh", ":DiffviewFileHistory<CR>", { silent = true, desc = "Git File History" })
			vim.keymap.set("n", "<leader>dc", ":DiffviewClose<CR>", { silent = true, desc = "Close Diff View" })
			vim.keymap.set("n", "<leader>df", ":DiffviewToggleFiles<CR>", { silent = true, desc = "Toggle Diff Files" })
			vim.keymap.set("n", "<leader>dr", ":DiffviewRefresh<CR>", { silent = true, desc = "Refresh Diff View" })
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
}
