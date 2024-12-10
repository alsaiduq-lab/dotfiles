return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "theHamsta/nvim-dap-virtual-text",
        "nvim-neotest/nvim-nio",
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        -- Basic DAP configurations
        dap.adapters.python = {
            type = 'executable',
            command = 'python',
            args = { '-m', 'debugpy.adapter' },
        }

        dap.configurations.python = {
            {
                type = 'python',
                request = 'launch',
                name = "Launch file",
                program = "${file}",
                pythonPath = function()
                    local venv = os.getenv('VIRTUAL_ENV')
                    if venv then
                        return venv .. '/Scripts/python'
                    end
                    return 'python'
                end,
            },
        }

        -- DAP UI
        dapui.setup()

        -- Automatically open/close dapui when debugging starts/ends
        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end

        -- Virtual Text
        require("nvim-dap-virtual-text").setup({
            enabled = true,
            enabled_commands = true,
            highlight_changed_variables = true,
            highlight_new_as_changed = false,
            show_stop_reason = true,
            commented = false,
            virt_text_pos = 'eol',
            all_frames = false,
            virt_lines = false,
            virt_text_win_col = nil
        })

        -- Keybindings
        vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP Continue" })
        vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP Step Over" })
        vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP Step Into" })
        vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP Step Out" })
        vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
        vim.keymap.set("n", "<leader>B", function()
            dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
        end, { desc = "DAP Set Conditional Breakpoint" })
        vim.keymap.set("n", "<leader>lp", function()
            dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
        end, { desc = "DAP Set Log Point" })
        vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "DAP Repl Toggle" })
        vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "DAP Run Last" })
    end,
}
