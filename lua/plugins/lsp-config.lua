_G.vim = vim
return {
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"onsails/lspkind.nvim",
		},
		config = function()
			local cmp = require("cmp")
			local lspkind = require("lspkind")
			cmp.setup({
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",
						maxwidth = 50,
						ellipsis_char = "...",
					}),
				},
				sources = {
					{ name = "nvim_lsp" },
				},
				mapping = cmp.mapping.preset.insert({}),
				snippet = {
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},
			})
		end,
	},
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "clangd", "cssls", "html", "pyright", "gopls", "denols" },
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"onsails/lspkind.nvim",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			local cmp_nvim_lsp = require("cmp_nvim_lsp")
			local lspconfig = require("lspconfig")
			local lspkind = require("lspkind")

			lspkind.init()

			vim.opt.signcolumn = "yes"

			local capabilities = vim.tbl_deep_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				cmp_nvim_lsp.default_capabilities()
			)

			local function setup_enhanced_diagnostics()
				local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
				for type, icon in pairs(signs) do
					local hl = "DiagnosticSign" .. type
					vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
				end

				vim.diagnostic.config({
					virtual_text = {
						prefix = "●",
						source = true,
						severity_sort = true,
					},
					float = {
						source = true,
						border = "rounded",
						header = "",
						prefix = "",
					},
					signs = true,
					underline = true,
					update_in_insert = false,
					severity_sort = true,
				})

				vim.api.nvim_create_user_command("DiagnosticNext", function()
					vim.diagnostic.goto_next()
					vim.defer_fn(function()
						vim.lsp.buf.code_action()
					end, 100)
				end, { desc = "Go to next diagnostic and show fixes" })

				vim.api.nvim_create_user_command("DiagnosticPrev", function()
					vim.diagnostic.goto_prev()
					vim.defer_fn(function()
						vim.lsp.buf.code_action()
					end, 100)
				end, { desc = "Go to previous diagnostic and show fixes" })

				vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
				vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
				vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show Diagnostic Details" })
				vim.keymap.set(
					"n",
					"<leader>q",
					vim.diagnostic.setloclist,
					{ desc = "Add Diagnostics to Location List" }
				)
			end

			local function open_dynamic_lsp_log()
				local log_path = vim.lsp.get_log_path()
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_get_name(buf) == log_path then
						vim.api.nvim_set_current_buf(buf)
						return
					end
				end
				vim.cmd("vnew")
				local buf = vim.api.nvim_get_current_buf()
				vim.api.nvim_buf_set_name(buf, "LSP Log")
				vim.bo[buf].buftype = "nofile"
				vim.bo[buf].modifiable = false
				local tail_command = "tail -f " .. log_path
				vim.fn.termopen(tail_command, {
					on_exit = function()
						vim.api.nvim_buf_delete(buf, { force = true })
					end,
				})
			end

			setup_enhanced_diagnostics()

			vim.api.nvim_create_user_command(
				"DynamicLspLog",
				open_dynamic_lsp_log,
				{ desc = "Open dynamic LSP log in a buffer" }
			)
			vim.keymap.set("n", "<leader>dl", ":DynamicLspLog<CR>", { desc = "Open dynamic LSP log" })

			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "LSP actions",
				callback = function(event)
					local opts = { buffer = event.buf }

					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, opts)
					vim.keymap.set({ "n", "x" }, "<F3>", function()
						vim.lsp.buf.format({ async = true })
					end, opts)

					local diagnostic_augroup = vim.api.nvim_create_augroup("DiagnosticCursor", { clear = true })
					vim.api.nvim_create_autocmd("CursorHold", {
						group = diagnostic_augroup,
						buffer = event.buf,
						callback = function()
							local diagnostics = vim.diagnostic.get(0, { lnum = vim.api.nvim_win_get_cursor(0)[1] - 1 })
							if #diagnostics > 0 and diagnostics[1].severity <= vim.diagnostic.severity.ERROR then
								vim.defer_fn(function()
									vim.lsp.buf.code_action()
								end, 100)
							end
						end,
					})
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "typescript", "javascript" },
				callback = function(ev)
					if vim.fn.filereadable(vim.fn.getcwd() .. "/deno.json") == 1 then
						if not vim.lsp.get_clients({ name = "denols" })[1] then
							lspconfig.denols.setup({
								capabilities = capabilities,
								root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc", "deps.ts"),
								init_options = {
									enable = true,
									lint = true,
									unstable = true,
									suggest = {
										imports = {
											hosts = {
												["https://deno.land"] = true,
											},
										},
									},
								},
								settings = {
									deno = {
										enable = true,
										lint = true,
										unstable = true,
										codeLens = {
											implementations = true,
											references = true,
										},
									},
								},
							})
							vim.cmd("LspStart denols")
						end
					end
				end,
			})

			local servers = {
				lua_ls = {
					capabilities = capabilities,
					settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							workspace = { library = vim.api.nvim_get_runtime_file("", true) },
						},
					},
				},
				clangd = { capabilities = capabilities },
				cssls = { capabilities = capabilities },
				html = { capabilities = capabilities },
				pyright = { capabilities = capabilities },
				gopls = { capabilities = capabilities },
			}

			for server, config in pairs(servers) do
				lspconfig[server].setup(config)
			end
		end,
	},
	{
		"nvimdev/lspsaga.nvim",
		event = "BufRead",
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			require("lspsaga").setup({
				ui = {
					border = "rounded",
				},
				lightbulb = {
					enable = true,
					sign = true,
				},
				code_action = {
					show_server_name = true,
				},
			})
		end,
	},
}
