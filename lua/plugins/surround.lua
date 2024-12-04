return {
  "kylechui/nvim-surround",
  event = { "BufReadPre", "BufNewFile" },
  version = "*",
  config = function()
    require("nvim-surround").setup({
      -- Keymaps for operating on surroundings (like brackets, quotes, etc)
      keymaps = {
        insert = "<C-g>s",     -- Add surrounding in insert mode
        insert_line = "<C-g>S", -- Add surrounding to line in insert mode
        normal = "ys",         -- Add surrounding in normal mode (ys + motion + char)
        normal_cur = "yss",    -- Add surrounding to current line
        normal_line = "yS",    -- Add surrounding to line with newlines
        normal_cur_line = "ySS", -- Add surrounding to current line with newlines
        visual = "S",          -- Add surrounding in visual mode
        visual_line = "gS",    -- Add surrounding to visual selection with newlines
        delete = "ds",         -- Delete surrounding (ds + char)
        change = "cs",         -- Change surrounding (cs + old + new)
      },
      -- Custom surrounding pairs with optional spacing
      surrounds = {
        ["("] = { add = { "( ", " )" } },  -- Add spaces inside parentheses
        [")"] = { add = { "(", ")" } },    -- No spaces inside parentheses
        ["{"] = { add = { "{ ", " }" } },  -- Add spaces inside curly braces
        ["}"] = { add = { "{", "}" } },    -- No spaces inside curly braces
        ["<"] = { add = { "< ", " >" } },  -- Add spaces inside angle brackets
        [">"] = { add = { "<", ">" } },    -- No spaces inside angle brackets
        ["["] = { add = { "[ ", " ]" } },  -- Add spaces inside square brackets
        ["]"] = { add = { "[", "]" } },    -- No spaces inside square brackets
      }
    })
  end
}
