return {
	"ahmedkhalf/project.nvim",
	event = "BufRead",
	config = function()
		local home_cargo = vim.fn.expand("~/.cargo/*")
		local target_dirs = "target/*"
		local home = vim.fn.expand("$HOME/*")

		require("project_nvim").setup({
			detection_methods = { "pattern", "lsp" },
			patterns = { ".git", "Makefile", "package.json" },
			exclude_dirs = { home_cargo, target_dirs, home },
			show_hidden = false,
			silent_chdir = true,
			ignore_lsp = {},
		})

		-- Integrate with Telescope
		require("telescope").load_extension("projects")
	end,
}
