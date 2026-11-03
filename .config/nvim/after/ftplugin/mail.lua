-- Disable hard line breaks for email editing
-- Allows natural soft wrapping without cutting lines at 72 chars
vim.opt_local.textwidth = 0
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.formatoptions:remove({ "t", "c" })
