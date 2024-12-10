return {
    "ahmedkhalf/project.nvim",
    event = "BufRead",
    config = function()
        require("project_nvim").setup({
            detection_methods = { "pattern", "lsp" },
            patterns = { ".git", "Makefile", "package.json" },
            exclude_dirs = { "~/.cargo/*", "target/*" },
            show_hidden = false,
            silent_chdir = true,
            ignore_lsp = {},
        })

        -- Integrate with Telescope
        require("telescope").load_extension("projects")
    end,
}
