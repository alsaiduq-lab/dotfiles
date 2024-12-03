_G.vim = vim
-- Configuration for the alpha-nvim plugin, which provides a dashboard for Neovim
return {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
        local dashboard = require("alpha.themes.dashboard")
        require("alpha.term")
        local arttoggle = false

        local logo = {
            [[                                                    ]],
            [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
            [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
            [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
            [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
            [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
            [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
            [[                                                    ]],
        }

        local art = {
            { "tohru", 62, 17 }, -- { name, width, height }
        }

        -- Conditional setup for dashboard display
        if arttoggle then
            -- Configure dashboard for terminal art display
            dashboard.opts.opts.noautocmd = true
            dashboard.section.terminal.opts.redraw = true
            local path = vim.fn.stdpath("config") .. "/assets/"
            local currentart = art[1]
            dashboard.section.terminal.command = "cat " .. path .. currentart[1]
            dashboard.section.terminal.width = currentart[2]
            dashboard.section.terminal.height = currentart[3]
            dashboard.opts.layout = {
                dashboard.section.terminal,
                { type = "padding", val = 2 },
                dashboard.section.buttons,
                dashboard.section.footer,
            }
        else
            -- Use logo if art is not toggled
            dashboard.section.header.val = logo
        end

        -- Define buttons for the dashboard
        dashboard.section.buttons.val = {
            dashboard.button("f", " " .. "Find files", ":Telescope find_files <CR>"),
        }

        -- Style the dashboard buttons
        for _, button in ipairs(dashboard.section.buttons.val) do
            button.opts.hl = "AlphaButtons"
            button.opts.hl_shortcut = "AlphaShortcut"
        end

        -- Set highlight groups for different sections of the dashboard
        dashboard.section.header.opts.hl = "Function"
        dashboard.section.buttons.opts.hl = "Identifier"
        dashboard.section.footer.opts.hl = "Function"
        dashboard.opts.layout[1].val = 4

        return dashboard
    end,

    -- Configuration function for setting up the dashboard
    config = function(_, dashboard)
        -- Handle the case when entering from a filetype 'lazy'
        if vim.o.filetype == "lazy" then
            vim.cmd.close()
            vim.api.nvim_create_autocmd("User", {
                pattern = "AlphaReady",
                callback = function()
                    require("lazy").show()
                end,
            })
        end

        require("alpha").setup(dashboard.opts)

        -- Update footer information when LazyVim has started
        vim.api.nvim_create_autocmd("User", {
            pattern = "LazyVimStarted",
            callback = function()
                local v = vim.version()
                local dev = v.prerelease == "dev" and "-dev+" .. v.build or ""
                local version = v.major .. "." .. v.minor .. "." .. v.patch .. dev
                local stats = require("lazy").stats()
                local plugins_count = stats.loaded .. "/" .. stats.count
                local ms = math.floor(stats.startuptime + 0.5)
                local time = vim.fn.strftime("%H:%M:%S")
                local date = vim.fn.strftime("%d.%m.%Y")
                local line1 = " " .. plugins_count .. " plugins loaded in " .. ms .. "ms"
                local line2 = "󰃭 " .. date .. "  " .. time
                local line3 = " " .. version

                local line1_width = vim.fn.strdisplaywidth(line1)
                local line2Padded = string.rep(" ", (line1_width - vim.fn.strdisplaywidth(line2)) / 2) .. line2
                local line3Padded = string.rep(" ", (line1_width - vim.fn.strdisplaywidth(line3)) / 2) .. line3

                dashboard.section.footer.val = {
                    line1,
                    line2Padded,
                    line3Padded,
                }
                pcall(vim.cmd.AlphaRedraw)
            end,
        })
    end,
}
