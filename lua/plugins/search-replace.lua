return {
    "nvim-pack/nvim-spectre",
    -- Search and replace in multiple files
    description = "Find and replace plugin with powerful search capabilities",
    dependencies = {
        "nvim-lua/plenary.nvim", -- Required for async operations
    },
    cmd = {
        "Spectre",   -- Main command
        "SpectreToggle", -- Toggle spectre window
        "SpectreClose", -- Close spectre window
    },
    keys = {
        { "<leader>S", "<cmd>Spectre<cr>", desc = "Open Spectre search/replace" },
    },
    opts = {
        color_devicons = true,
        highlight = {
            ui = "String",
            search = "DiffChange",
            replace = "DiffDelete"
        },
        mapping = {
            ["toggle_line"] = {
                map = "dd",
                cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
                desc = "toggle current item"
            },
            ["run_replace"] = {
                map = "<leader>r",
                cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
                desc = "replace all"
            },
        },
    },
    -- Lazy load on command
    config = true,
}
