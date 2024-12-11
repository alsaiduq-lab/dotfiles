return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			javascript = { "eslint", "standardjs" },
			typescript = { "eslint", "standardjs" },
			javascriptreact = { "eslint", "standardjs" },
			typescriptreact = { "eslint", "standardjs" },
			python = { "pylint", "flake8", "mypy", "ruff" },
			lua = { "luacheck", "selene" },
			markdown = { "markdownlint", "vale" },
			css = { "stylelint", "prettier" },
			html = { "htmlhint", "tidy" },
			yaml = { "yamllint", "actionlint" },
			json = { "jsonlint", "prettier" },
			dockerfile = { "hadolint", "dockerfilelint" },
			sh = { "shellcheck", "bashate", "shellharden" },
			rust = { "clippy" },
			go = { "golangci-lint", "revive" },
			ruby = { "rubocop", "standardrb" },
			php = { "phpcs", "phpstan" },
			c = { "cpplint", "clang-tidy" },
			cpp = { "cpplint", "clang-tidy" },
			java = { "checkstyle", "pmd" },
			xml = { "xmllint" },
			sql = { "sqlfluff", "sqlfmt" },
			vue = { "eslint" },
			svelte = { "eslint" },
			terraform = { "tflint" },
			proto = { "buf-lint" },
			cmake = { "cmakelint" },
			dart = { "dartanalyzer" },
		}

		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		local last_lint = {}
		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			group = lint_augroup,
			callback = function()
				local bufnr = vim.api.nvim_get_current_buf()
				if not vim.api.nvim_buf_is_valid(bufnr) then
					return
				end

				local filetype = vim.bo.filetype
				if not filetype or filetype == "" then
					return
				end

				if not lint.linters_by_ft[filetype] then
					return
				end

				local current_time = os.time() * 1000
				local last_lint_time = last_lint[bufnr] or 0
				local debounce_interval = 5000

				if current_time - last_lint_time > debounce_interval then
					require("notify")("Linting " .. filetype .. " file...", "info", {
						title = "Nvim-Lint",
						timeout = 2000,
					})

					local ok, err = pcall(function()
						lint.try_lint()
					end)

					if not ok then
						require("notify")("Linting error: " .. tostring(err), "error", {
							title = "Nvim-Lint",
						})
					end

					last_lint[bufnr] = current_time
				end
			end,
		})

		vim.diagnostic.config({
			underline = true,
			virtual_text = {
				spacing = 4,
				prefix = "●",
				severity = {
					min = vim.diagnostic.severity.HINT,
				},
			},
			signs = true,
			update_in_insert = false,
			severity_sort = true,
			float = {
				border = "rounded",
				source = true,
				header = "",
				prefix = "",
			},
		})

		local signs = {
			Error = "✘",
			Warn = "▲",
			Hint = "⚑",
			Info = "»",
		}
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
		end
	end,
}
