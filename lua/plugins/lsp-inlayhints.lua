return {
    "lvimuser/lsp-inlayhints.nvim",
    event = "LspAttach",
    config = function()
        require("lsp-inlayhints").setup({
            inlay_hints = {
                parameter_hints = {
                    show = true,
                    prefix = "← ",
                    separator = ", ",
                    remove_colon_start = false,
                    remove_colon_end = true,
                },
                type_hints = {
                    show = true,
                    prefix = "=> ",
                    separator = ", ",
                    remove_colon_start = false,
                    remove_colon_end = false,
                },
                label_separator = "  ",
                max_len_align = false,
                max_len_align_padding = 1,
                right_align = false,
                right_align_padding = 7,
                highlight = "Comment",
            },
            enabled_at_startup = true,
            debug_mode = false,
        })
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                if not (args.data and args.data.client_id) then
                    return
                end
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client then
                    require("lsp-inlayhints").on_attach(client, args.buf)
                end
            end,
        })
    end,
}
