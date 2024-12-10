return {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function()
        require("lsp_signature").setup({
            bind = true,
            doc_lines = 10,
            hint_enable = true,
            floating_window = true,
            floating_window_above_cur_line = true,
            handler_opts = {
                border = "rounded",
            },
        })
    end,
}

