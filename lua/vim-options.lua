-- Basic Settings
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.syntax = "enable"
vim.opt.showcmd = true
vim.opt.encoding = "utf-8"
vim.opt.showmatch = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.softtabstop = 0
vim.opt.autoindent = true
vim.opt.smarttab = true

-- Window Navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Navigate to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Navigate to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Navigate to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Navigate to right window" })

-- Quick Save
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Quick save" })

-- Buffer Navigation
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { desc = "Previous buffer" })

-- Window Management
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split horizontally" })
vim.keymap.set("n", "<leader>sq", ":close<CR>", { desc = "Close window" })

-- Window Resizing
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Better indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Move selected line / block of text in visual mode
vim.keymap.set("x", "K", ":move '<-2<CR>gv-gv", { desc = "Move line up" })
vim.keymap.set("x", "J", ":move '>+1<CR>gv-gv", { desc = "Move line down" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Navigate to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Navigate to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Navigate to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Navigate to right window" })

-- Stay in indent mode after indenting
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
