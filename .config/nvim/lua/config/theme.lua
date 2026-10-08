local function toggle_theme()
  if vim.o.background == "dark" then
    vim.o.background = "light"
    vim.cmd('colorscheme default')
  else
    vim.o.background = "dark"
    vim.cmd('colorscheme medallion')
  end
end

vim.api.nvim_create_user_command('ToggleTheme', toggle_theme, {desc = 'Toggle between dark and light theme'})
