return {
  'nvim-telescope/telescope.nvim',
  cmd = {"Telescope"},
  dependencies = {
    'nvim-lua/plenary.nvim',
  }
}

-- return {
--     "nvim-telescope/telescope.nvim", branch = "0.1.x",
--     cmd = {"Telescope"},
--     dependencies = {
--       'nvim-lua/plenary.nvim',
--       "nvim-telescope/telescope-bibtex.nvim",
--       {
--         'nvim-telescope/telescope-fzf-native.nvim',
--         build = 'make',
--         cond = function()
--           require('telescope').load_extension('fzf')
--           return vim.fn.executable 'make' == 1
--         end,
--       },
--     },
--     opts = {
--       defaults = {
--         mappings = {
--           i = {
--             ['<C-u>'] = false,
--             ['<C-d>'] = false,
--           },
--         },
--       },
--     }
-- }
--
