return {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
        require("ufo").setup({
            open_fold_hl_timeout = 0,
            close_fold_kinds = {},
            provider_selector = function(bufnr, filetype, buftype)
                return { "treesitter", "indent" }
            end,
            fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
                local newVirtText = {}
                local suffix = ('  %d lines'):format(endLnum - lnum)
                local sufWidth = vim.fn.strdisplaywidth(suffix)
                local targetWidth = width - sufWidth
                local curWidth = 0
                
                -- Only set fold level if it hasn't been manually set
                if vim.b.fold_level_set ~= true then
                    local fileSize = vim.fn.line('$')
                    if fileSize > 2000 then
                        vim.opt.foldlevel = 0
                    elseif fileSize > 1000 then
                        vim.opt.foldlevel = 1
                    elseif fileSize > 500 then
                        vim.opt.foldlevel = 2
                    elseif fileSize > 250 then
                        vim.opt.foldlevel = 3
                    else
                        vim.opt.foldlevel = 99
                    end
                    vim.b.fold_level_set = true
                end

                for _, chunk in ipairs(virtText) do
                    local chunkText = chunk[1]
                    local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    if targetWidth > curWidth + chunkWidth then
                        table.insert(newVirtText, chunk)
                    else
                        chunkText = truncate(chunkText, targetWidth - curWidth)
                        local hlGroup = chunk[2]
                        table.insert(newVirtText, {chunkText, hlGroup})
                        chunkWidth = vim.fn.strdisplaywidth(chunkText)
                        if curWidth + chunkWidth < targetWidth then
                            suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                        end
                        break
                    end
                    curWidth = curWidth + chunkWidth
                end
                table.insert(newVirtText, {suffix, 'MoreMsg'})
                return newVirtText
            end,
        })

        -- Keybindings for folding that override automatic settings
        vim.keymap.set("n", "ZT", function()
            vim.opt.foldlevel = 99
            vim.b.fold_level_set = true
            require("ufo").openAllFolds()
        end, { desc = "Open All Folds" })
        vim.keymap.set("n", "ZE", function()
            require("ufo").closeAllFolds()
            vim.cmd("normal! zM")
            vim.opt.foldlevel = 0
            vim.b.fold_level_set = true
        end, { desc = "Close All Folds" })
    end,
}
