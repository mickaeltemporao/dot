require("config.options")
require("config.plugins")
require("config.keymaps")
require("misc.agent")

local empty_buffer_group = vim.api.nvim_create_augroup("EmptyBufferWrap", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
  group = empty_buffer_group,
  callback = function()
    local ft = vim.bo.filetype
    local is_empty_content = (vim.api.nvim_buf_line_count(0) == 1 and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == "")
    if ft == "" or is_empty_content then
      vim.opt_local.wrap = true
    end
  end,
})

