_G.vim = vim

local M = {
  setup = function()
    if vim.fn.has('win32') == 1 then
      vim.g.loaded_python_provider = 0
      vim.g.python3_host_prog = vim.fn.expand('$LOCALAPPDATA') .. '/Programs/Python/Python312/python.exe'
      vim.opt.emoji = true
      vim.opt.encoding = "utf-8"
      vim.opt.fileencoding = "utf-8"
      vim.opt.ambiwidth = "single"
      vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
        pattern = {"*"},
        callback = function()
          vim.opt_local.fileencoding = "utf-8"
          vim.opt_local.bomb = false
        end
      })
    end
  end
}

return M
