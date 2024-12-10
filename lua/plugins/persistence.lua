return {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
        dir = vim.fn.stdpath("data") .. "/sessions/",
        options = { "buffers", "curdir", "tabpages", "winsize" },
    },
    keys = {
        { "<leader>sl", function() require("persistence").load() end, desc = "Restore Session" },
        { "<leader>ss", function() require("persistence").save() end, desc = "Save Session" },
        { "<leader>sd", function() require("persistence").stop() end, desc = "Stop Persistence" },
    },
}
