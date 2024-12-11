_G.vim = vim

local M = {
	setup = function()
		if vim.fn.has("win32") == 1 then
			vim.g.loaded_python_provider = 0

			local possible_paths = {
				vim.fn.expand("$LOCALAPPDATA") .. "/Programs/Python/Python312/python.exe",
				vim.fn.expand("$LOCALAPPDATA") .. "/Programs/Python/Python311/python.exe",
				vim.fn.expand("$LOCALAPPDATA") .. "/Programs/Python/Python310/python.exe",
				vim.fn.expand("$LOCALAPPDATA") .. "/Programs/Python/Python39/python.exe",
				vim.fn.expand("$LOCALAPPDATA") .. "/Microsoft/WindowsApps/python.exe",
				"C:/Python312/python.exe",
				"C:/Python311/python.exe",
				"C:/Python310/python.exe",
				"C:/Python39/python.exe",
			}

			for _, path in ipairs(possible_paths) do
				if vim.fn.executable(path) == 1 then
					vim.g.python3_host_prog = path
					break
				end
			end

			vim.opt.emoji = true
			vim.opt.encoding = "utf-8"
			vim.opt.fileencoding = "utf-8"
			vim.opt.ambiwidth = "single"
			vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
				pattern = { "*" },
				callback = function()
					vim.opt_local.fileencoding = "utf-8"
					vim.opt_local.bomb = false
				end,
			})
		end
	end,
}

return M
