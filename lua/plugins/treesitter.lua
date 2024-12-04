return {
  "nvim-treesitter/nvim-treesitter", -- Main Treesitter plugin for Neovim
  event = { "BufReadPre", "BufNewFile" }, -- Load plugin when opening/creating files
  build = ":TSUpdate", -- Run TSUpdate when installing/updating
  dependencies = { 
    "nvim-treesitter/nvim-treesitter-textobjects", -- Adds text objects support
    "windwp/nvim-ts-autotag" -- Provides auto closing/renaming of HTML tags
  },
  config = function()
    -- auto close and auto rename html tags
    require("nvim-ts-autotag").setup({})
    
    -- treesitter configuration
    require("nvim-treesitter.configs").setup({
      highlight = { enable = true }, -- Enable syntax highlighting
      auto_install = true, -- Automatically install parsers
      ensure_installed = { -- List of language parsers to install
        "json",
        "javascript", 
        "typescript",
        "tsx",
        "yaml",
        "html",
        "astro",
        "css",
        "markdown",
        "markdown_inline",
        "svelte",
        "graphql",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "query",
        "vimdoc",
        "c",
        "rust",
      },
    })
  end,
}
