return {
	"Pocco81/auto-save.nvim",
	event = { "InsertLeave", "TextChanged", "FocusLost", "BufLeave", "CursorHold", "CursorHoldI" },
	dependencies = {
		"rcarriga/nvim-notify",
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local notify = require("notify")
		local icons = {
			save = "💾",
			warning = "⚠️",
			error = "❌",
			success = "✨",
		}

		local last_notification_time = 0
		local notification_cooldown = 2000

		local function format_file_size(size)
			local units = { "B", "KB", "MB", "GB" }
			local unit_index = 1
			while size > 1024 and unit_index < #units do
				size = size / 1024
				unit_index = unit_index + 1
			end
			return string.format("%.2f%s", size, units[unit_index])
		end

		local function show_save_notification(filename, time)
			local current_time = vim.loop.now()
			if current_time - last_notification_time < notification_cooldown then
				return
			end
			last_notification_time = current_time

			local file_path = vim.fn.expand("%:p")
			local file_size = vim.fn.getfsize(file_path)
			local formatted_size = format_file_size(file_size)

			local git_status = ""
			local ok, _ = pcall(require, "gitsigns")
			if ok then
				local signs = vim.fn.sign_getplaced(vim.fn.bufnr(), { group = "gitsigns" })[1]
				if #signs > 0 then
					git_status = " (uncommitted changes)"
				end
			end

			local title = icons.success .. " File Saved"
			local message = string.format("%s\nSize: %s%s\nTime: %s", filename, formatted_size, git_status, time)

			notify(message, "info", {
				title = title,
				timeout = 1500,
				animate = true,
				render = "minimal",
				icon = icons.save,
			})
		end

		local function handle_save_error(filename, error_msg)
			notify(string.format("Failed to save %s\nError: %s", filename, error_msg), "error", {
				title = icons.error .. " Save Error",
				timeout = 5000,
				animate = true,
				render = "minimal",
			})
		end

		require("auto-save").setup({
			enabled = true,
			trigger_events = {
				"InsertLeave",
				"TextChanged",
				"FocusLost",
				"BufLeave",
				"CursorHold",
				"CursorHoldI",
			},
			execution_message = {
				message = function()
					local modified = vim.bo.modified
					if modified then
						local time = vim.fn.strftime("%H:%M:%S")
						local filename = vim.fn.expand("%:t")

						-- Try to save the file
						local ok, err = pcall(vim.cmd, "silent write")
						if ok then
							show_save_notification(filename, time)
						else
							handle_save_error(filename, err)
						end

						return ""
					end
					return ""
				end,
				dim = 0.18,
				cleaning_interval = 1000,
			},
			condition = function(buf)
				local utils = require("auto-save.utils.data")
				local filename = vim.fn.expand("%:t")

				local file_size = vim.fn.getfsize(vim.fn.expand("%:p"))
				if file_size > 10 * 1024 * 1024 then
					notify(
						string.format(
							"File '%s' is too large for auto-save (%.2fMB)",
							filename,
							file_size / 1024 / 1024
						),
						"warn",
						{
							title = icons.warning .. " Auto-save skipped",
							timeout = 3000,
						}
					)
					return false
				end

				local excluded_filetypes = {
					"neo-tree",
					"TelescopePrompt",
					"lazy",
					"terminal",
					"prompt",
					"noice",
					"notify",
					"mason",
					"qf",
					"help",
					"gitcommit",
					"DressingInput",
					"git",
					"undotree",
					"diff",
					"fugitive",
				}

				-- Don't autosave if:
				if
					vim.bo.readonly
					or vim.bo.buftype ~= ""
					or not vim.bo.modifiable
					or vim.fn.filereadable(filename) == 0
					or utils.not_in(vim.bo.filetype, excluded_filetypes)
				then
					return false
				end

				-- Don't save during completion
				local pumvisible = vim.fn.pumvisible() == 1
				local completing = vim.fn.complete_info().mode ~= nil
				return not (pumvisible or completing)
			end,
			write_all_buffers = false,
			debounce_delay = 300,
			throttle_duration = 1500,

			on_off_commands = true,
			on_enable_hook = function()
				notify("Auto-save enabled", "info", {
					title = icons.success .. " Auto-save",
					timeout = 2000,
				})
			end,
			on_disable_hook = function()
				notify("Auto-save disabled", "warn", {
					title = icons.warning .. " Auto-save",
					timeout = 2000,
				})
			end,
		})

		-- Add commands to toggle auto-save
		vim.api.nvim_create_user_command("AutoSaveToggle", function()
			require("auto-save").toggle()
		end, {})
	end,
}
