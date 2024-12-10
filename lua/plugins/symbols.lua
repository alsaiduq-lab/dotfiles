return {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
    config = function()
        require("symbols-outline").setup({
            -- Optional configurations
            highlight_hovered_item = true,
            show_guides = true,
            width = 25,
            auto_close = true,
            keymaps = { -- These can be customized
                close = {"<Esc>", "q"},
                goto_location = "<Cr>",
                focus_location = "o",
                hover_symbol = "K",
                toggle_preview = "P",
            },
        })
    end,
}
