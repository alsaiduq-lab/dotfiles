---@diagnostic disable: undefined-field
_G.vim = _G.vim or vim

return {
	"mhartington/formatter.nvim",
	event = "BufWritePre",
	opts = {},
	config = function()
		local util = require("formatter.util")

		local function formatter_exists(formatter)
			return vim.fn.executable(formatter) == 1
		end

		local function prettier_config(parser)
			return function()
				if not formatter_exists("prettier") then
					vim.notify("prettier not found. Please install it!", vim.log.levels.WARN)
					return nil
				end
				return {
					exe = "prettier",
					args = {
						"--stdin-filepath",
						util.escape_path(util.get_current_buffer_file_path()),
						parser and "--parser" or nil,
						parser,
						"--single-quote",
						"--jsx-single-quote",
					},
					stdin = true,
					try_node_modules = true,
				}
			end
		end

		require("formatter").setup({
			logging = true,
			log_level = vim.log.levels.WARN,
			filetype = {
				lua = {
					function()
						if not formatter_exists("stylua") then
							vim.notify("stylua not found. Please install it!", vim.log.levels.WARN)
							return nil
						end
						return require("formatter.filetypes.lua").stylua
					end,
				},
				javascript = prettier_config(),
				typescript = prettier_config(),
				javascriptreact = prettier_config(),
				typescriptreact = prettier_config(),
				json = prettier_config("json"),
				yaml = prettier_config("yaml"),
				html = prettier_config("html"),
				css = prettier_config("css"),
				scss = prettier_config("scss"),
				markdown = prettier_config("markdown"),
				python = {
					function()
						if not formatter_exists("autopep8") then
							vim.notify("autopep8 not found. Please install it!", vim.log.levels.WARN)
							return nil
						end
						return {
							exe = "autopep8",
							args = {
								"--aggressive",
								"--aggressive",
								"--max-line-length",
								"120",
								"--experimental",
								"--in-place",
								"--ignore",
								"E226,E24,W50,W690,E731",
								"-",
							},
							stdin = true,
						}
					end,
				},
				rust = {
					function()
						if not formatter_exists("rustfmt") then
							vim.notify("rustfmt not found. Please install it!", vim.log.levels.WARN)
							return nil
						end
						return {
							exe = "rustfmt",
							args = { "--edition", "2021" },
							stdin = true,
						}
					end,
				},
				go = {
					function()
						if not formatter_exists("gofmt") then
							vim.notify("gofmt not found. Please install it!", vim.log.levels.WARN)
							return nil
						end
						return {
							exe = "gofmt",
							stdin = true,
						}
					end,
				},
				cpp = {
					function()
						if not formatter_exists("clang-format") then
							vim.notify("clang-format not found. Please install it!", vim.log.levels.WARN)
							return nil
						end
						return {
							exe = "clang-format",
							args = {
								"--assume-filename",
								util.escape_path(util.get_current_buffer_file_path()),
								"--style=Google",
							},
							stdin = true,
						}
					end,
				},
				c = {
					function()
						if not formatter_exists("clang-format") then
							vim.notify("clang-format not found. Please install it!", vim.log.levels.WARN)
							return nil
						end
						return {
							exe = "clang-format",
							args = {
								"--assume-filename",
								util.escape_path(util.get_current_buffer_file_path()),
								"--style=Google",
							},
							stdin = true,
						}
					end,
				},
				java = {
					function()
						if not formatter_exists("google-java-format") then
							vim.notify("google-java-format not found. Please install it!", vim.log.levels.WARN)
							return nil
						end
						return {
							exe = "google-java-format",
							args = {
								"--aosp",
								util.escape_path(util.get_current_buffer_file_path()),
							},
							stdin = true,
						}
					end,
				},
				php = {
					function()
						if not formatter_exists("php-cs-fixer") then
							vim.notify("php-cs-fixer not found. Please install it!", vim.log.levels.WARN)
							return nil
						end
						return {
							exe = "php-cs-fixer",
							args = { "fix", "--rules=@PSR2", "-" },
							stdin = true,
						}
					end,
				},
				ruby = {
					function()
						if not formatter_exists("rubocop") then
							vim.notify("rubocop not found. Please install it!", vim.log.levels.WARN)
							return nil
						end
						return {
							exe = "rubocop",
							args = {
								"--auto-correct",
								"--stdin",
								util.escape_path(util.get_current_buffer_file_path()),
								"--format",
								"quiet",
								"--stderr",
							},
							stdin = true,
						}
					end,
				},
				sh = {
					function()
						if not formatter_exists("shfmt") then
							vim.notify("shfmt not found. Please install it!", vim.log.levels.WARN)
							return nil
						end
						return {
							exe = "shfmt",
							args = { "-i", "2", "-bn", "-ci", "-sr" },
							stdin = true,
						}
					end,
				},
				["*"] = {
					function()
						return {
							exe = "vim",
							args = {},
							stdin = false,
							transform = function(text)
								return text:gsub("%s+$", "")
							end,
						}
					end,
				},
			},
		})

		local format_group = vim.api.nvim_create_augroup("FormatAutogroup", { clear = true })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = format_group,
			pattern = "*",
			callback = function()
				if not vim.b.disable_autoformat then
					vim.cmd.Format({})
				end
			end,
			desc = "Format on save",
		})

		vim.api.nvim_create_user_command("FormatToggle", function()
			vim.b.disable_autoformat = not vim.b.disable_autoformat
			if vim.b.disable_autoformat then
				vim.notify("Autoformat disabled", vim.log.levels.INFO)
			else
				vim.notify("Autoformat enabled", vim.log.levels.INFO)
			end
		end, { desc = "Toggle autoformat on save" })
	end,
}
