-- plugins/navic.lua
return {
    "SmiteshP/nvim-navic",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
        require("nvim-navic").setup({
            highlight = true,
            separator = " > ",
            icons = {
                File = "",
                Module = "",
                Namespace = "",
                Package = "",
                Class = "",
                Method = "",
                Property = "",
                Field = "",
                Constructor = "",
                Enum = "練",
                Interface = "練",
                Function = "",
                Variable = "",
                Constant = "",
                String = "",
                Number = "",
                Boolean = "◩",
                Array = "",
                Object = "",
                Key = "",
                Null = "ﳠ",
                EnumMember = "",
                Struct = "",
                Event = "",
                Operator = "",
                TypeParameter = "",
            },
        })
    end,
}