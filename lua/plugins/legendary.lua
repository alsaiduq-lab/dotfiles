-- plugins/legendary.lua
return {
    "mrjones2014/legendary.nvim",
    cmd = "Legendary",
    config = function()
        require("legendary").setup({
            -- Optional configurations
            which_key = {
                auto_register = true,
            },
        })
    end,
}
