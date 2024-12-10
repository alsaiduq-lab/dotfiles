return {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        -- Initialize none-ls (null-ls) for linting and formatting
        local null_ls = require("null-ls")

        -- Define formatting and linting sources for different languages
        local sources = {
            -- JavaScript/TypeScript: Prettier for consistent code formatting
            null_ls.builtins.formatting.prettier.with({
                filetypes = { "javascript", "typescript", "css", "html", "json", "yaml", "markdown" }
            }),

            -- Python formatting and linting tools
            null_ls.builtins.formatting.black, -- Code formatter
            null_ls.builtins.formatting.isort, -- Import sorter
            null_ls.builtins.diagnostics.pylint.with({
                prefer_local = ".venv/bin"     -- Use project's virtual environment
            }),
            null_ls.builtins.diagnostics.mypy, -- Static type checker

            -- Lua formatting
            null_ls.builtins.formatting.stylua, -- Modern Lua formatter

            -- Go formatting tools
            null_ls.builtins.formatting.gofmt,     -- Standard Go formatter
            null_ls.builtins.formatting.goimports, -- Manages Go imports

            -- Shell script formatting
            null_ls.builtins.formatting.shfmt, -- Shell script formatter
        }

        -- Setup automatic formatting on file save
        local function format_on_save(client, bufnr)
            -- Check if the LSP client supports formatting
            if client.supports_method("textDocument/formatting") then
                -- Create an autocommand for the current buffer
                vim.api.nvim_create_autocmd("BufWritePre", {
                    group = vim.api.nvim_create_augroup("FormatOnSave" .. bufnr, { clear = true }),
                    buffer = bufnr,
                    callback = function()
                        -- Format the buffer before saving
                        vim.lsp.buf.format({ bufnr = bufnr })
                    end,
                })
            end
        end

        -- Configure none-ls with the specified sources and format-on-save
        null_ls.setup({
            sources = sources,
            on_attach = format_on_save,
            debug = true -- Enable debug logging
        })
    end,
}
