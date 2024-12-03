-- Enable line numbers
vim.cmd("set number")
-- Enable mouse support in all modes
vim.cmd("set mouse=a")
-- Enable syntax highlighting
vim.cmd("syntax enable")
-- Show command as it's being typed
vim.cmd("set showcmd")
-- Set encoding to UTF-8
vim.cmd("set encoding=utf-8")
-- Highlight matching brackets when cursor is on them
vim.cmd("set showmatch")
-- Enable relative line numbers
vim.cmd("set relativenumber")
-- Convert tabs to spaces
vim.cmd("set expandtab")
-- Set the number of visual spaces per TAB
vim.cmd("set tabstop=4")
-- Make 'shiftwidth' to follow 'tabstop'
vim.cmd("set shiftwidth=0")
-- Set soft tab stop to 0, which makes it follow 'tabstop'
vim.cmd("set softtabstop=0")
-- Auto indent new lines
vim.cmd("set autoindent")
-- Use smart tabs
vim.cmd("set smarttab")
-- Keymap to navigate between windows using Ctrl + h/l
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Navigate to left window" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Navigate to right window" })
