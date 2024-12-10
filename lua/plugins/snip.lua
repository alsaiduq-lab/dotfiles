return {
	"L3MON4D3/LuaSnip",
	lazy = true, -- Only load the plugin when needed
	event = "InsertEnter", -- Trigger loading when user enters insert mode
	config = function()
		local luasnip = require("luasnip")

		-- Configure LuaSnip's core behavior
		luasnip.setup({
			history = true, -- Keep track of snippet history for undo/redo
			updateevents = "TextChanged,TextChangedI", -- Events that trigger snippet updates
			enable_autosnippets = true, -- Allow snippets to trigger automatically
		})

		-- Configure snippet sources:
		-- 1. Load standard VSCode-style snippets
		require("luasnip.loaders.from_vscode").lazy_load()
		-- 2. Load custom snippets from local ./snippets directory
		require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })

		-- Create command to reload snippets during development
		-- Usage: :LuaSnipReload
		vim.api.nvim_create_user_command("LuaSnipReload", function()
			require("luasnip").cleanup() -- Remove existing snippets from memory
			require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })
			print("LuaSnip snippets reloaded!")
		end, { desc = "Reload LuaSnip snippets" })

		-- Snippet Navigation Keymaps
		-- <C-j>: Move to next snippet placeholder
		vim.keymap.set("i", "<C-j>", function()
			if luasnip.jumpable(1) then
				luasnip.jump(1)
			end
		end, { silent = true, desc = "Jump to next snippet placeholder" })

		-- <C-k>: Move to previous snippet placeholder
		vim.keymap.set("i", "<C-k>", function()
			if luasnip.jumpable(-1) then
				luasnip.jump(-1)
			end
		end, { silent = true, desc = "Jump to previous snippet placeholder" })

		-- <C-l>: Cycle through choices in choice nodes
		-- Choice nodes allow selecting from multiple options
		vim.keymap.set("i", "<C-l>", function()
			if luasnip.choice_active() then
				luasnip.change_choice(1)
			end
		end, { silent = true, desc = "Cycle through snippet choices" })
	end,
}
