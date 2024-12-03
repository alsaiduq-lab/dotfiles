-- Plugins can be lazy-loaded by specifying conditions under which they should be loaded.
-- Here's an example of how lazy loading might be configured:

-- **Using Lazy.nvim**:
-- ```lua
-- require("lazy").setup({
--     {
--         "username/plugin-name",
--         -- This plugin will load when a file with the extension '.ext' is opened
--         ft = "ext",
--         -- Or load when a specific command is run
--         cmd = "SomeCommand",
--         -- Or load when a certain event occurs
--         event = "BufRead",
--         -- Or load when a specific key is pressed
--         keys = "<leader>somekey",
--         -- Or load after a delay
--         config = function() vim.defer_fn(function() require("plugin-name").setup() end, 100) end
--     }
-- })
-- ```

-- Note: Replace 'username/plugin-name' with the actual plugin name or GitHub repo.
-- The `ft`, `cmd`, `event`, `keys`, and `config` options are just examples; 
-- you can use one or multiple of these conditions to trigger plugin loading.

return {}
