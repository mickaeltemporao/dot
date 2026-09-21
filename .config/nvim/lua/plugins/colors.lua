return {
  dir = vim.fn.expand("~/Documents/code/medallion.nvim"),
  name = "medallion.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("medallion")
  end
}
