_G.vim = vim
return {
  {
    'vyfor/cord.nvim',
    lazy = false,
    build = vim.fn.has('win32') and 'powershell.exe -c .\\build.bat' or './build',
    config = function()
      require('cord').setup({
        usercmds = true,
        timer = {
          interval = 1500,
        },
        display = {
          show_time = true,
          show_repository = true,
          show_cursor_position = true,
          swap_fields = false,
        },
        text = {
          editing = 'Editing {}',
          viewing = 'Viewing {}',
          workspace = 'In {}',
        },
      })
    end
  }
}
