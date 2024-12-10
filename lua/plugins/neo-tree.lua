_G.vim = vim
return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        require("neo-tree").setup({
            filesystem = {
                filtered_items = {
                    visible = false,
                },
                follow_current_file = { enabled = true, },
                use_libuv_file_watcher = true,
                window = {
                    mappings = {
                        ["<leader>f"] = "filter_on_submit",
                        ["<leader>F"] = "clear_filter",
                    },
                },
            },
            icons = {
                default = "",
                symlink = "",
                git_deleted = "✖",
                git_ignored = "◌",
                git_modified = "",
                git_new = "✚",
                git_renamed = "➜",
                git_untracked = "★",
                folder = {
                    default = "",
                    open = "",
                    empty = "",
                    empty_open = "",
                },
            },
        })
        vim.keymap.set('n', '<C-n>', ':Neotree filesystem reveal left<CR>', {})
    end
}
