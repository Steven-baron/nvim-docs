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

-- Tab settings (Go prefers tabs, web dev prefers spaces)
-- Web default (2 spaces)
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.softtabstop = 2

-- Go will override these with file-specific settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

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

--nvim-tree
keymap('n', '<space>e', ':NvimTreeToggle<CR>', {noremap = true})

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

-- Go specific keymaps
keymap('n', '<leader>gr', ':GoRun<CR>', { noremap = true, desc = 'Go Run' })
keymap('n', '<leader>gt', ':GoTest<CR>', { noremap = true, desc = 'Go Test' })
keymap('n', '<leader>gtf', ':GoTestFunc<CR>', { noremap = true, desc = 'Go Test Function' })
keymap('n', '<leader>gb', ':GoBuild<CR>', { noremap = true, desc = 'Go Build' })
keymap('n', '<leader>gi', ':GoImports<CR>', { noremap = true, desc = 'Go Imports' })
keymap('n', '<leader>gd', ':GoDoc<CR>', { noremap = true, desc = 'Go Doc' })

-- [[ Telescope Keymaps ]]
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<space>fb', ':Telescope file_browser<CR>', { noremap = true })
keymap('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
keymap('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
keymap('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
keymap('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
keymap('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
keymap('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })
keymap('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
keymap('n', '<leader>.', builtin.oldfiles, { desc = '[.] Find recently opened files' })

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

-- Plugin specifications
require('lazy').setup({
  -- LSP Support
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      -- Setup Mason first
      require('mason').setup({})
      
      -- Then setup mason-lspconfig
      require('mason-lspconfig').setup({
        ensure_installed = {
          'gopls',           -- Go
          'tsserver',        -- TypeScript/JavaScript
          'html',            -- HTML
          'cssls',           -- CSS
          'tailwindcss',     -- Tailwind CSS
          'eslint',          -- ESLint
          'jsonls',          -- JSON
        },
        automatic_installation = true
      })
      
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr }
        -- LSP keymaps
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts)
      end

      -- Go LSP setup
      require('lspconfig').gopls.setup{
        capabilities = capabilities,
        on_attach = on_attach,
        cmd = {"gopls", "serve"},
        filetypes = {"go", "gomod", "gowork", "gotmpl"},
        root_dir = require('lspconfig').util.root_pattern("go.work", "go.mod", ".git"),
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      }

      -- TypeScript/JavaScript LSP setup
      require('lspconfig').tsserver.setup{
        capabilities = capabilities,
        on_attach = on_attach,
        filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      }

      -- HTML LSP setup
      require('lspconfig').html.setup{
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- CSS LSP setup
      require('lspconfig').cssls.setup{
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- Tailwind CSS LSP setup
      require('lspconfig').tailwindcss.setup{
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- ESLint LSP setup
      require('lspconfig').eslint.setup{
        capabilities = capabilities,
        on_attach = on_attach,
      }

      -- JSON LSP setup
      require('lspconfig').jsonls.setup{
        capabilities = capabilities,
        on_attach = on_attach,
      }
    end
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
    },
  },

  -- Go development
  {
    'fatih/vim-go',
    ft = {'go'},
    build = ':GoInstallBinaries',
    config = function()
      -- vim-go settings
      vim.g.go_highlight_fields = 1
      vim.g.go_highlight_functions = 1
      vim.g.go_highlight_function_calls = 1
      vim.g.go_highlight_extra_types = 1
      vim.g.go_highlight_operators = 1
      vim.g.go_highlight_build_constraints = 1
      
      -- Auto formatting and importing
      vim.g.go_fmt_autosave = 1
      vim.g.go_fmt_command = "goimports"
      
      -- Status line types/signatures
      vim.g.go_auto_type_info = 1
      
      -- Use gopls
      vim.g.go_gopls_enabled = 1
      
      -- Disable vim-go :GoDef short cut (gd)
      -- This is handled by LSP
      vim.g.go_def_mapping_enabled = 0
    end
  },

  -- nvim-tree
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {'nvim-tree/nvim-web-devicons'},
    config = function()
      require("nvim-tree").setup()
    end
  },

  -- Syntax Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = { 
          "go", "gomod", "gowork",             -- Go
          "javascript", "typescript", "tsx",   -- JS/TS
          "html", "css",                       -- HTML/CSS
          "json", "yaml", "markdown",          -- Data formats
          "lua"                                -- Lua for config
        },
        highlight = { enable = true },
        indent = { enable = true },
      }
    end
  },

  -- Git integration
  'lewis6991/gitsigns.nvim',

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  {
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
  },

  -- Theme
  'folke/tokyonight.nvim',

  -- Status line
  'nvim-lualine/lualine.nvim',

  -- Which key
  'folke/which-key.nvim',

  -- Comment
  'numToStr/Comment.nvim',

  -- Autopairs
  'windwp/nvim-autopairs',

  -- React/JSX support
  'maxmellon/vim-jsx-pretty',

  -- Web development helpers
  {
    'norcalli/nvim-colorizer.lua',  -- Color highlighter
    config = function()
      require('colorizer').setup({'css', 'html', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact'})
    end
  },
  
  -- Emmet support for HTML/CSS
  'mattn/emmet-vim',
})

-- [[ Plugin Configuration ]]

-- Theme setup
vim.cmd[[colorscheme tokyonight]]

-- Configure which-key
require('which-key').setup({
  plugins = {
    marks = true,
    registers = true,
    spelling = {
      enabled = false,
    },
    presets = {
      operators = true,
      motions = true,
      text_objects = true,
      windows = true,
      nav = true,
      z = true,
      g = true,
    },
  },
})

-- Setup nvim-cmp
local cmp = require('cmp')
local luasnip = require('luasnip')

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
})

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

-- Setup gitsigns
require('gitsigns').setup()

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

-- Emmet configuration
vim.g.user_emmet_leader_key = '<C-z>'  -- Press Ctrl-z, then comma (,) to expand
vim.g.user_emmet_install_global = 0
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"html", "css", "javascriptreact", "typescriptreact"},
  callback = function()
    vim.cmd("EmmetInstall")
  end,
})

-- Telescope configuration 
require('telescope').setup({
  defaults = {
    initial_mode = 'insert', -- Set to 'insert' for a more normal experience
    mappings = {
      i = {
        ['<C-j>'] = 'move_selection_next',
        ['<C-k>'] = 'move_selection_previous',
      }
    }
  },
  extensions = {
    file_browser = {
      theme = "dropdown",
      hijack_netrw = true,
    },
  }
})

-- Load Telescope extensions
require("telescope").load_extension("file_browser")
