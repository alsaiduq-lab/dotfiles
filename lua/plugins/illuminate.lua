return {
    "RRethy/vim-illuminate",
    event = "BufRead",
    config = function()
        -- Configure vim-illuminate plugin
        -- This plugin automatically highlights other uses of the word under cursor
        require("illuminate").configure({
            -- Specify which providers to use for finding references
            -- lsp: use language server
            -- treesitter: use syntax tree
            -- regex: fallback to regex matching
            providers = { "lsp", "treesitter", "regex" },

            -- Delay in milliseconds before highlighting
            delay = 100,

            -- List of filetypes where the plugin should not run
            filetypes_denylist = {
                "alpha",      -- dashboard screen
                "dashboard",  -- another dashboard plugin
                "NvimTree",   -- file explorer
                "neo-tree",   -- another file explorer
                "Trouble",    -- diagnostics list
                "toggleterm", -- terminal window
            },
        })

        -- Navigation keymaps for moving between references
        -- ]e moves to next reference
        vim.api.nvim_set_keymap("n", "]e", '<cmd>lua require("illuminate").next_reference{wrap=true}<CR>',
            { noremap = true, silent = true })

        -- [e moves to previous reference
        vim.api.nvim_set_keymap("n", "[e", '<cmd>lua require("illuminate").next_reference{reverse=true, wrap=true}<CR>',
            { noremap = true, silent = true })
    end,
}
