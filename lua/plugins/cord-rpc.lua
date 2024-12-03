_G.vim = vim
return {
  {
    'vyfor/cord.nvim',
    lazy = false,
    build = 'powershell.exe -c .\\build.bat',
    -- Note: The following configuration only works for Windows. Linux and macOS users need to adjust the build command.
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
