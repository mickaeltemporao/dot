-- interface
-- vim.opt.cmdheight=0
-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- vim.opt.foldtext = "v:lua.vim.treesitter.foldtext()"
vim.opt.foldlevel = 99
vim.opt.completeopt = 'menuone,noselect' -- better completion experience
vim.opt.colorcolumn = '80' -- highlight over length lines
vim.opt.cursorline = true -- highlight current line
vim.opt.list = true -- display unprintable characters f12 - switches
vim.opt.listchars = { tab = [[→→]], trail = '•', extends = '»', precedes = '«' }  -- {tab = '••'|'>~',eol = '↴'|'¶'|'$', nbsp = '␣'|'%', space = '_' }
vim.opt.mouse = 'a' -- automatically enable mouse usage
vim.opt.number = true -- line numbers
vim.opt.splitbelow = true
vim.opt.splitright = true -- open new split panes to right and below and next line
vim.opt.termguicolors = true -- enable terminalgui colors
vim.opt.updatetime = 100 -- quick diagnostic messages default 4000.
vim.opt.writebackup = true -- make a backup before overwriting a file.
vim.opt_global.diffopt:append({ 'vertical' }) -- diff mode always vertical split

-- general
vim.opt.clipboard = 'unnamedplus' -- use system clipboard by default
vim.opt.timeoutlen = 250 -- milliseconds to wait for code sequence
vim.opt.undodir = os.getenv('HOME') .. '/.config/nvim/undo' -- undo locatoin
vim.opt.undofile = true -- persistent undo
vim.opt.undolevels = 10000 -- maximum number of changes that can be undone.
vim.opt.backup = true --to recover from you can use the backup file directly
vim.opt_global.backupdir = { os.getenv('HOME') .. '/.config/nvim/backup' }  -- directories for backup file
vim.opt.backupcopy = 'auto' -- tells neovim how backups are done
vim.opt.backupext = '.vimbak' -- the extension to be used for vim backup files
vim.opt.swapfile = true -- enable saving unsaved/unwritten files in a *.swp file

-- search
vim.opt.hlsearch = true -- set highlight on search
vim.opt.ignorecase = true -- ignore case 
vim.opt.smartcase = true -- don't ignore case if specified 

-- code
vim.opt.tabstop = 2 -- number of spaces a tab takes
vim.opt.shiftwidth = 2 -- number of characters used for indentation
vim.opt.softtabstop = 2 -- number of spaces a tab counts when editing
vim.opt.expandtab = true -- transform tab to spaces
vim.opt.wrap = false -- disable wrap lines
vim.opt.breakindent = true -- keep wraped lines indented

-- netrw 
-- vim.g.netrw_altv = 1
vim.g.netrw_banner = 0
-- vim.g.netrw_keepdir = 0
-- vim.g.netrw_liststyle = 3
-- vim.g.netrw_preview = 1
-- vim.g.netrw_winsize = 30
-- vim.g.netrw_browse_split = 4

-- global variables
vim.g.mapleader = ' ' -- map leader to space bar
vim.g.maplocalleader = '\\' -- map local leader to backspace 
vim.g.python3_host_prog = os.getenv('HOME') .. '/.pyenv/versions/3.13.2/bin/python3' -- python path
vim.g.loaded_python_provider = 0 -- disable Python2 support
vim.g.loaded_perl_provider = 0 -- disable perl provider
vim.g.loaded_ruby_provider = 0 -- disable ruby provider
vim.g.loaded_node_provider = 0 -- disable node provider
