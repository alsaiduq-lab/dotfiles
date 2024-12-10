return {
    "sindrets/diffview.nvim",
    event = "VeryLazy",
    config = function()
        local actions = require("diffview.actions")
        require("diffview").setup({
            enhanced_diff_hl = true,
            view = {
                default = {
                    layout = "diff2_horizontal",
                },
            },
            hooks = {
                view_opened = function(view)
                    local bufnr = vim.api.nvim_get_current_buf()
                    if not (bufnr and vim.api.nvim_buf_is_valid(bufnr)) then
                        return
                    end
                    if vim.bo[bufnr].filetype ~= "DiffviewFiles" then
                        vim.bo[bufnr].buftype = "nofile"
                        vim.bo[bufnr].modifiable = false
                        vim.bo[bufnr].readonly = true
                        vim.bo[bufnr].filetype = "git"
                        vim.b[bufnr].diffview_rpc = "Viewing git diff"
                        vim.bo[bufnr].buflisted = false
                    end
                end,
                view_closed = function()
                    vim.cmd("bufdo bwipeout")
                    vim.cmd("silent! %bdelete!")
                    vim.cmd("clearjumps")
                    if vim.fn.bufexists('#') == 1 then
                        vim.cmd("e #")
                    end
                end,
                file_open = function(bufnr)
                    if not (bufnr and vim.api.nvim_buf_is_valid(bufnr)) then
                        return
                    end
                    if vim.bo[bufnr].filetype ~= "DiffviewFiles" then
                        vim.bo[bufnr].buftype = "nofile"
                        vim.bo[bufnr].modifiable = false
                        vim.bo[bufnr].readonly = true
                        vim.bo[bufnr].filetype = "git"
                        vim.bo[bufnr].buflisted = false

                        local file_name = vim.fn.expand('%:t')
                        if file_name and file_name ~= '' then
                            vim.b[bufnr].diffview_rpc = "Viewing git diff: " .. file_name
                        end
                    end
                end,
            },
            keymaps = {
                view = {
                    ["q"] = actions.close,
                },
                file_panel = {
                    ["q"] = actions.close,
                },
            },
        })
        vim.keymap.set("n", "<leader>do", ":DiffviewOpen<CR>", { silent = true, desc = "Git Diff View" })
    end,
    dependencies = {
        "nvim-lua/plenary.nvim",
    }
}
