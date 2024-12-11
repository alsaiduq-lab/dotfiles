return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		local status_ok, toggleterm = pcall(require, "toggleterm")
		if not status_ok then
			return
		end
		toggleterm.setup({
			size = function(term)
				if term.direction == "horizontal" then
					return vim.o.lines * 0.4
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.4
				end
				return 20
			end,
			open_mapping = [[<c-\>]],
			shade_filetypes = {},
			shade_terminals = true,
			shading_factor = 1,
			start_in_insert = true,
			insert_mappings = true,
			terminal_mappings = true,
			persist_size = true,
			direction = "float",
			close_on_exit = true,
			shell = vim.o.shell,
			float_opts = {
				border = "single",
				width = function()
					return math.floor(vim.o.columns * 0.85)
				end,
				height = function()
					return math.floor(vim.o.lines * 0.85)
				end,
				winblend = 0,
				title_pos = "center",
			},
			winbar = {
				enabled = true,
				name_formatter = function(term)
					return term.name
				end,
			},
			highlights = {
				NormalFloat = {
					link = "Normal",
				},
				FloatBorder = {
					link = "FloatBorder",
				},
			},
		})

		local Terminal = require("toggleterm.terminal").Terminal
		local lazygit = Terminal:new({
			cmd = "lazygit",
			hidden = true,
			direction = "float",
			float_opts = {
				border = "single",
				width = function()
					return math.floor(vim.o.columns * 0.9)
				end,
				height = function()
					return math.floor(vim.o.lines * 0.9)
				end,
			},
		})

		-- Fixed function name
		local function _LAZYGIT_TOGGLE()
			lazygit:toggle()
		end

		-- Fixed function name
		local function set_terminal_keymaps()
			local opts = { buffer = 0 }
			vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
			vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
			vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
			vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
			vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
		end

		vim.api.nvim_create_autocmd("TermOpen", {
			pattern = "term://*",
			callback = set_terminal_keymaps,
		})

		local opts = { noremap = true, silent = true }
		vim.keymap.set(
			"n",
			"<leader>tt",
			":ToggleTerm<CR>",
			vim.tbl_extend("force", opts, { desc = "Toggle Terminal" })
		)
		vim.keymap.set(
			"n",
			"<leader>th",
			":ToggleTerm direction=horizontal<CR>",
			vim.tbl_extend("force", opts, { desc = "Toggle Horizontal Terminal" })
		)
		vim.keymap.set(
			"n",
			"<leader>tv",
			":ToggleTerm direction=vertical<CR>",
			vim.tbl_extend("force", opts, { desc = "Toggle Vertical Terminal" })
		)
		vim.keymap.set(
			"n",
			"<leader>tf",
			":ToggleTerm direction=float<CR>",
			vim.tbl_extend("force", opts, { desc = "Toggle Float Terminal" })
		)

		vim.keymap.set("n", "<leader>tg", function()
			_LAZYGIT_TOGGLE()
		end, vim.tbl_extend("force", opts, { desc = "Toggle Lazygit" }))
	end,
}
