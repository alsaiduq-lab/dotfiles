_G.vim = vim
return {
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
			"onsails/lspkind.nvim",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")
			require("luasnip.loaders.from_vscode").lazy_load()

			local has_words_before = function()
				unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = {
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				},
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text",
						maxwidth = 50,
						ellipsis_char = "...",
						menu = {
							nvim_lsp = "[LSP]",
							luasnip = "[Snippet]",
							buffer = "[Buffer]",
							path = "[Path]",
						},
					}),
				},
				completion = {
					completeopt = "menu,menuone,noselect",
				},
			})

			vim.api.nvim_set_keymap("i", "<S-Tab>", "<C-p>", { noremap = true, silent = true })
			vim.api.nvim_set_keymap("i", "<C-h>", "<C-p>", { noremap = true, silent = true })
			vim.cmd([[
				inoremap <S-Tab> <C-p>
				inoremap <C-h> <C-p>
			]])

			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
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

					local diagnostic_augroup = vim.api.nvim_create_augroup("Diagnostic", { clear = true })
				end,
			})
		end,
	},
}
