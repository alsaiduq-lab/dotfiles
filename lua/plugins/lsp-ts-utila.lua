-- plugins/lsp-ts-utils.lua
return {
    "jose-elias-alvarez/nvim-lsp-ts-utils",
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    config = function()
        local lspconfig = require("lspconfig")
        local ts_utils = require("nvim-lsp-ts-utils")

        -- Setup your LSP server (e.g., tsserver)
        lspconfig.tsserver.setup({
            on_attach = function(client, bufnr)
                -- defaults
                ts_utils.setup({
                    debug = false,
                    disable_commands = false,
                    enable_import_on_completion = false,
                    import_all_timeout = 5000, -- ms
                    -- additional_options
                })
                ts_utils.setup_client(client)

                -- Required to make the module works
                ts_utils.setup_imports()

                -- Keymaps
                local opts = { silent = true, buffer = bufnr }
                vim.keymap.set("n", "gs", ":TSLspOrganize<CR>", opts)
                vim.keymap.set("n", "gi", ":TSLspRenameFile<CR>", opts)
                vim.keymap.set("n", "go", ":TSLspImportAll<CR>", opts)
            end,
        })
    end,
}

