-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Basic Options ]]
local opt = vim.opt

-- Enable syntax highlighting and filetype detection
vim.cmd('syntax enable')
vim.cmd('filetype plugin indent on')

-- Set basic vim options
opt.autoindent = true
opt.autoread = true
opt.background = 'dark'
opt.backspace = 'indent,eol,start'
opt.belloff = 'all'
opt.clipboard = 'unnamedplus'
opt.cursorline = true
opt.display = 'lastline'
opt.encoding = 'utf-8'
opt.hidden = true
opt.history = 10000
opt.ignorecase = true
opt.incsearch = true
opt.joinspaces = false
opt.laststatus = 2
opt.mouse = 'a'
opt.number = true
opt.ruler = true
opt.scrolloff = 11
opt.showmode = false
opt.signcolumn = 'yes'
opt.smartcase = true
opt.smarttab = true

-- Basic tab settings
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.softtabstop = 2

opt.splitbelow = true
opt.splitright = true
opt.startofline = false
opt.timeoutlen = 300
opt.updatetime = 250

-- Set list chars
opt.list = true
opt.listchars = {
    tab = '» ',
    trail = '·',
    nbsp = '␣'
}

-- [[ Basic Keymaps ]]
local keymap = vim.keymap.set

-- Clear search highlighting with <Esc>
keymap('n', '<Esc>', ':nohlsearch<CR>', { silent = true })

-- Terminal mode escape
keymap('t', '<Esc><Esc>', '<C-\\><C-n>', { silent = true })

-- Better window navigation
keymap('n', '<C-h>', '<C-w><C-h>', { silent = true })
keymap('n', '<C-l>', '<C-w><C-l>', { silent = true })
keymap('n', '<C-j>', '<C-w><C-j>', { silent = true })
keymap('n', '<C-k>', '<C-w><C-k>', { silent = true })

-- Disable arrow keys in normal mode
keymap('n', '<left>', ':echo "Use h to move!!"<CR>', { silent = true })
keymap('n', '<right>', ':echo "Use l to move!!"<CR>', { silent = true })
keymap('n', '<up>', ':echo "Use k to move!!"<CR>', { silent = true })
keymap('n', '<down>', ':echo "Use j to move!!"<CR>', { silent = true })

-- Word wrap navigation
keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Plugin Installation ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications - minimal set for basic editing
require('lazy').setup({
  -- nvim-tree for file browsing
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {'nvim-tree/nvim-web-devicons'},
    config = function()
      require("nvim-tree").setup()
    end
  },

  -- Theme
  'folke/tokyonight.nvim',

  -- Status line
  'nvim-lualine/lualine.nvim',

  -- Comment
  'numToStr/Comment.nvim',

  -- Autopairs
  'windwp/nvim-autopairs',
})

-- [[ Plugin Configuration ]]

-- Theme setup
vim.cmd[[colorscheme tokyonight]]

-- Setup Comment.nvim
require('Comment').setup()

-- Setup lualine
require('lualine').setup({
  options = {
    theme = 'tokyonight',
    component_separators = { left = '|', right = '|'},
    section_separators = { left = '', right = ''},
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'},
  },
})

-- Setup autopairs
require('nvim-autopairs').setup({
  disable_filetype = { "TelescopePrompt" },
  disable_in_macro = false,
  disable_in_visualblock = false,
  ignored_next_char = [=[[%w%%%'%[%"%.]]=],
  enable_moveright = true,
  enable_afterquote = true,
  enable_check_bracket_line = true,
})

-- nvim-tree keymaps
keymap('n', '<space>e', ':NvimTreeToggle<CR>', {noremap = true})

