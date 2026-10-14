local local_path = vim.fn.expand("~/Documents/code/aigent")

return {
  "mickaeltemporao/aigent.nvim",
  dir = vim.fn.isdirectory(local_path) == 1 and local_path or nil,
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  opts = {},
}
