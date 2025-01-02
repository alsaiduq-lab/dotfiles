return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = true,
          suggestions = 20,
        },
        presets = {
          operators = true,
          motions = true,
          text_objects = true,
          windows = true,
          nav = true,
          z = true,
          g = true,
        },
      },
      -- Remove or comment out the conflicting operator
      --operators = {},
      key_labels = {
        ["<space>"] = "SPC",
        ["<cr>"] = "RET",
        ["<tab>"] = "TAB",
      },
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
      },
      popup_mappings = {
        scroll_down = "<c-d>",
        scroll_up = "<c-u>",
      },
      window = {
        border = "rounded",
        position = "bottom",
        margin = { 1, 0, 1, 0 },
        padding = { 2, 2, 2, 2 },
        winblend = 0,
      },
      layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = "left",
      },
      ignore_missing = true,
      hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },
      show_help = true,
      show_keys = true,
      triggers = "auto",
      triggers_blacklist = {
        i = { "j", "k" },
        v = { "j", "k" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      wk.register({
        f = {
          name = "File",
          f = { "<cmd>Telescope find_files<cr>", "Find File" },
          r = { "<cmd>Telescope oldfiles<cr>", "Recent Files" },
          s = { "<cmd>Telescope live_grep<cr>", "Live Grep" },
        },
        b = {
          name = "Buffer",
          b = { "<cmd>Telescope buffers<cr>", "Switch Buffer" },
          d = { "<cmd>bdelete<cr>", "Delete Buffer" },
        },
        w = {
          name = "Window",
          v = { "<cmd>vsplit<cr>", "Vertical Split" },
          s = { "<cmd>split<cr>", "Horizontal Split" },
          h = { "<c-w>h", "Go Left" },
          j = { "<c-w>j", "Go Down" },
          k = { "<c-w>k", "Go Up" },
          l = { "<c-w>l", "Go Right" },
        },
      }, { prefix = "<leader>" })
    end,
  },
}

