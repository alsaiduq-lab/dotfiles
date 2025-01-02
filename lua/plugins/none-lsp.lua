return {
	"nvimtools/none-ls.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"mason.nvim",
	},
	config = function()
		local none_ls = require("none-ls")

		local function find_venv()
			local launch_venv = os.getenv("VIRTUAL_ENV")
			if
				launch_venv
				and (
					vim.fn.isdirectory(launch_venv .. "/bin") == 1
					or vim.fn.isdirectory(launch_venv .. "\\Scripts") == 1
				)
			then
				return launch_venv .. (vim.fn.has("win32") == 1 and "\\Scripts" or "/bin")
			end

			local project_venv_paths = {
				".venv/bin",
				"venv/bin",
				"env/bin",
				".venv\\Scripts",
				"venv\\Scripts",
				"env\\Scripts",
			}

			local current_dir = vim.fn.getcwd()
			for _, path in ipairs(project_venv_paths) do
				local full_path = current_dir .. "/" .. path
				if vim.fn.isdirectory(full_path) == 1 then
					return full_path:gsub("/", "\\")
				end
			end

			return nil
		end

		local sources = {
			none_ls.builtins.formatting.prettier.with({
				filetypes = { "javascript", "typescript", "css", "html", "json", "yaml", "markdown" },
			}),

			none_ls.builtins.formatting.black,
			none_ls.builtins.formatting.isort,
			none_ls.builtins.diagnostics.pylint.with({
				prefer_local = find_venv(),
			}),
			none_ls.builtins.diagnostics.mypy.with({
				prefer_local = find_venv(),
			}),

			none_ls.builtins.formatting.stylua,

			none_ls.builtins.formatting.gofmt,
			none_ls.builtins.formatting.goimports,

			none_ls.builtins.formatting.shfmt,
		}

		if vim.fn.has("win32") ~= 1 then
			table.insert(sources, none_ls.builtins.diagnostics.shellcheck)
		end

		local function on_attach(client, bufnr)
			if client.supports_method("textDocument/formatting") then
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = vim.api.nvim_create_augroup("FormatOnSave" .. bufnr, { clear = true }),
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format({ bufnr = bufnr })
					end,
				})
			end

			if client.supports_method("textDocument/publishDiagnostics") then
				vim.lsp.handlers["textDocument/publishDiagnostics"] =
					vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
						underline = true,
						virtual_text = { spacing = 4, prefix = "●" },
						signs = true,
						update_in_insert = false,
					})
			end
		end

		none_ls.setup({
			sources = sources,
			on_attach = on_attach,
			debug = true,
		})
	end,
}
