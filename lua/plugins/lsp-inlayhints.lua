return {
    "lvimuser/lsp-inlayhints.nvim",
    event = "LspAttach",
    config = function()
        require("lsp-inlayhints").setup({
            inlay_hints = {
                parameter_hints = {
                    show = true,
                },
                type_hints = {
                    show = true,
                },
            },
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
