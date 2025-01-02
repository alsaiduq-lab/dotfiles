_G.vim = vim

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	lazy = false,
	priority = 999,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	init = function()
		if vim.fn.argc() == 1 then
			local stat = vim.loop.fs_stat(vim.fn.argv(0))
			if stat and stat.type == "directory" then
				require("neo-tree")
			end
		end
	end,
	config = function()
		require("neo-tree").setup({
			close_if_last_window = true,
			popup_border_style = "rounded",
			enable_git_status = true,
			enable_diagnostics = true,
			sort_case_insensitive = true,
			auto_clean_after_session_restore = true,
			use_default_mappings = false,
			filesystem = {
				filtered_items = {
					visible = false,
					hide_dotfiles = true,
					hide_gitignored = true,
					hide_by_name = {
						"node_modules",
						".git",
					},
					never_show = {
						".DS_Store",
						"thumbs.db",
					},
				},
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true,
				hijack_netrw_behavior = "open_default",
				window = {
					mappings = {
						["<leader>f"] = "filter_on_submit",
						["<leader>F"] = "clear_filter",
						["<space>"] = "toggle_node",
						["<2-LeftMouse>"] = "open",
						["<cr>"] = "open",
						["S"] = "open_split",
						["s"] = "open_vsplit",
						["t"] = "open_tabnew",
						["C"] = "close_node",
						["z"] = "close_all_nodes",
						["R"] = "refresh",
						["a"] = "add",
						["d"] = "delete",
						["r"] = "rename",
						["y"] = "copy_to_clipboard",
						["x"] = "cut_to_clipboard",
						["p"] = "paste_from_clipboard",
						["c"] = "copy",
						["m"] = "move",
						["q"] = "close_window",
					},
				},
			},
			window = {
				position = "left",
				width = 35,
				mapping_options = {
					noremap = true,
					nowait = true,
				},
			},
			source_selector = {
				winbar = true,
				statusline = false,
				sources = {
					{ source = "filesystem" },
					{ source = "buffers" },
					{ source = "git_status" },
				},
			},
			icons = {
				default = "󰈚",
				symlink = "󰱔",
				bookmark = "󰆤",
				link = "󰌹",
				folder_closed = "󰉋",
				folder_open = "󰷏",
				folder_empty = "󰜌",
				folder_empty_open = "󰜌",
				modified = "●",
				close = "󰄴",
				new = "󰐕",
				git_staged = "✓",
				git_unstaged = "✗",
				git_deleted = "󰅖",
				git_ignored = "󰨀",
				git_modified = "󰜉",
				git_new = "󰜏",
				git_renamed = "󰁕",
				git_untracked = "󰧞",
				folder = {
					default = "󰉋",
					open = "󰷏",
					empty = "󰜌",
					empty_open = "󰜌",
				},
			},
		})
		vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>", { silent = true })
		vim.keymap.set("n", "<leader>bf", ":Neotree buffers reveal float<CR>", { silent = true })
		vim.keymap.set("n", "<leader>gs", ":Neotree git_status reveal float<CR>", { silent = true })
	end,
}
