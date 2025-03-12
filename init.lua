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
opt.tabstop = 4
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
     'Hoffs/omnisharp-extended-lsp.nvim',
     -- Add DAP related dependencies
     'mfussenegger/nvim-dap',
     'rcarriga/nvim-dap-ui',
     'theHamsta/nvim-dap-virtual-text',
     'jay-babu/mason-nvim-dap.nvim',
     'nvim-neotest/nvim-nio',
   },
   config = function()
     -- Set debug logging first
     vim.lsp.set_log_level("debug")
     require('vim.lsp.log').set_format_func(vim.inspect)
     
     -- Setup Mason first with debug logging
     require('mason').setup({
         log_level = vim.log.levels.DEBUG
     })
     
     -- Then setup mason-lspconfig and mason-dap
     require('mason-lspconfig').setup({
         ensure_installed = {'omnisharp'},
         automatic_installation = true
     })

     require("mason-nvim-dap").setup({
         ensure_installed = { "coreclr" },
         automatic_installation = true
     })

     -- DAP Setup
     local dap = require('dap')
     dap.adapters.coreclr = {
         type = 'executable',
         command = vim.fn.stdpath("data") .. '/mason/packages/netcoredbg/netcoredbg',
         args = {'--interpreter=vscode'}
     }

     dap.configurations.cs = {
         {
             type = "coreclr",
             name = "launch - netcoredbg",
             request = "launch",
             program = function()
                 return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
             end,
         },
     }

     -- Setup DAP UI
     require("nvim-dap-virtual-text").setup()
     require("dapui").setup()

     local dapui = require("dapui")
     dap.listeners.after.event_initialized["dapui_config"] = function()
         dapui.open()
     end
     dap.listeners.before.event_terminated["dapui_config"] = function()
         dapui.close()
     end
     dap.listeners.before.event_exited["dapui_config"] = function()
         dapui.close()
     end
     
     local capabilities = require('cmp_nvim_lsp').default_capabilities()
     local on_attach = function(_, bufnr)
         local opts = { buffer = bufnr }
         -- Existing LSP keymaps
         vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
         vim.keymap.set('n', 'gd', require('omnisharp_extended').telescope_lsp_definitions, opts)
         vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
         vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
         vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
         vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
         vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
         vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
         vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, opts)

         -- Debug keymaps
         vim.keymap.set('n', '<F5>', function() require('dap').continue() end, opts)
         vim.keymap.set('n', '<F10>', function() require('dap').step_over() end, opts)
         vim.keymap.set('n', '<F11>', function() require('dap').step_into() end, opts)
         vim.keymap.set('n', '<F12>', function() require('dap').step_out() end, opts)
         vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end, opts)
         vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint() end, opts)
         vim.keymap.set('n', '<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, opts)
         vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end, opts)
         -- Optional DAP UI keymaps
         vim.keymap.set('n', '<Leader>du', function() require('dapui').toggle() end, opts)
     end

     -- OmniSharp setup with improved handlers
     require('lspconfig').omnisharp.setup{
         capabilities = capabilities,
         on_attach = function(client, bufnr)
             print("OmniSharp attached to buffer: " .. vim.api.nvim_buf_get_name(bufnr))
             on_attach(client, bufnr)
             client.server_capabilities.semanticTokensProvider = nil
         end,
         handlers = {
             ["textDocument/definition"] = require('omnisharp_extended').handler,
         },
         cmd = { "dotnet", vim.fn.stdpath("data") .. "/mason/packages/omnisharp/libexec/OmniSharp.dll" },
         root_dir = require('lspconfig').util.root_pattern("*.sln", "*.csproj", ".git"),
         settings = {
             FormattingOptions = {
                 EnableEditorConfigSupport = true
             },
             RoslynExtensionsOptions = {
                 EnableAnalyzersSupport = true,
                 EnableImportCompletion = true
             },
             Sdk = {
                 IncludePrereleases = true
             }
         }
     }

     -- Other LSP setups
     require('lspconfig').ts_ls.setup{
         capabilities = capabilities,
         on_attach = on_attach,
     }
     require('lspconfig').html.setup{
         capabilities = capabilities,
         on_attach = on_attach,
     }
     require('lspconfig').cssls.setup{
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
    },
  },
--nvim-tree
  {
	'nvim-tree/nvim-tree.lua',
	depencencies = {'nvim-tree/nvim-web-devicons'},
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
        ensure_installed = { "c_sharp" },
        highlight = { enable = true },
      }
    end
  },

  -- Git integration
  'lewis6991/gitsigns.nvim',

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    require('telescope').setup({
    	defaults = {
		initial_mode = 'normal'
	}

    })
  },

  -- Theme
  'folke/tokyonight.nvim',

  -- Status line
  'nvim-lualine/lualine.nvim',

  -- Which key
  'folke/which-key.nvim',

  -- Comment
  'numToStr/Comment.nvim',
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
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
})

-- Setup Comment.nvim
require('Comment').setup()

-- Setup lualine
require('lualine').setup({
  options = {
    theme = 'tokyonight'
  }
})

-- Setup gitsigns
require('gitsigns').setup()

-- Telescope extension
require("telescope").load_extension("file_browser")

