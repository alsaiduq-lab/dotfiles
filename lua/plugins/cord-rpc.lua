_G.vim = _G.vim or vim

return {
	{
		"vyfor/cord.nvim",
		lazy = false,
		build = vim.fn.has("win32") == 1 and "powershell.exe -c .\\build.bat" or "./build",
		config = function()
			local ok, cord = pcall(require, "cord")
			if not ok then
				return
			end

			local setup_ok, _ = pcall(function()
				cord.setup({
					debug = true,
					timer = {
						interval = 1000,
					},
					display = {
						show_time = true,
						show_repository = true,
						show_cursor_position = true,
					},
					text = {
						editing = "Editing {}",
						viewing = "Viewing {}",
						file_browser = "Browsing files in {}",
						plugin_manager = "Managing plugins in {}",
						lsp_manager = "Configuring LSP in {}",
						vcs = "Reviewing changes in {}",
						workspace = "In {}",
					},
					assets = {
						DiffviewFiles = {
							name = "Git Diff",
							icon = "git",
							tooltip = "Viewing Git Changes",
							type = "vcs",
						},
					},
					auto_connect = true,
					check_discord = true,
				})
			end)

			if not setup_ok then
				return
			end

			pcall(function()
				vim.api.nvim_create_autocmd("VimEnter", {
					callback = function()
						vim.schedule(function()
							if cord and cord.state then
								pcall(function()
									return cord.state.is_connected
								end)
							end
						end)
					end,
				})
			end)
		end,
	},
}
