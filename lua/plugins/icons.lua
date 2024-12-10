return {
    "kyazdani42/nvim-web-devicons",
    lazy = true, -- Load when needed
    config = function()
        require("nvim-web-devicons").setup({
            default = true,
        })
    end,
}
