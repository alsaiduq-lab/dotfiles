return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")
		local notify = require("notify")

		lint.linters_by_ft = {
			javascript = { "eslint", "biomejs" },
			typescript = { "eslint", "biomejs" },
			javascriptreact = { "eslint", "biomejs" },
			typescriptreact = { "eslint", "biomejs" },
			python = { "ruff", "pylint", "flake8", "mypy", "pyright" },
			lua = { "luacheck", "selene" },
			markdown = { "markdownlint", "vale" },
			css = { "stylelint", "prettier" },
			html = { "htmlhint", "prettier" },
			yaml = { "yamllint", "prettier" },
			json = { "jsonlint", "prettier" },
			dockerfile = { "hadolint", "prettier" },
			sh = { "shellcheck", "shfmt" },
			rust = { "clippy", "rustfmt" },
			go = { "golangci-lint", "gofmt" },
			ruby = { "rubocop", "standardrb" },
			php = { "phpcs", "php-cs-fixer" },
			c = { "cpplint", "clang-format" },
			cpp = { "cpplint", "clang-format" },
			java = { "checkstyle", "google-java-format" },
			xml = { "xmllint", "prettier" },
			sql = { "sqlfluff", "pg_format" },
			vue = { "eslint", "prettier" },
			svelte = { "eslint", "prettier" },
			terraform = { "tflint", "terraform-fmt" },
			proto = { "buf-lint", "buf-format" },
			cmake = { "cmakelint", "cmake-format" },
			dart = { "dartanalyzer", "dart-format" },
			kotlin = { "ktlint" },
			scala = { "scalafmt" },
			swift = { "swiftlint" },
			elixir = { "credo" },
			haskell = { "hlint" },
			r = { "lintr" },
			ocaml = { "ocamlformat" },
			nim = { "nimpretty" },
			perl = { "perltidy", "perlcritic" },
			powershell = { "psscriptanalyzer" },
			graphql = { "graphql-lint" },
		}

		local function try_lint()
			local bufnr = vim.api.nvim_get_current_buf()
			if vim.api.nvim_buf_is_valid(bufnr) then
				notify("Linting...", "info")
				lint.try_lint()
				notify("Lint complete!", "success")
			end
		end

		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			callback = try_lint,
		})

		vim.keymap.set("n", "<leader>l", function()
			try_lint()
		end, { desc = "Trigger linting" })

		vim.diagnostic.config({
			underline = true,
			virtual_text = true,
			signs = true,
			update_in_insert = false,
			severity_sort = true,
		})

		local signs = {
			Error = "✖",
			Warn = "⚠",
			Hint = "💡",
			Info = "ℹ",
		}
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
		end
	end,
}
