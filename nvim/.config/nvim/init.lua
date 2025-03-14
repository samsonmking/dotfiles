-- Disable netrw for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- VSCode + Neovim Options
vim.opt.ignorecase = true                -- Use case insensitive search
vim.opt.smartcase = true                 -- Except when using capital letters
vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 10                 -- Quickly time out on keycodes, but never time out on mappings

-- Exit early if in VSCode
if vim.g.vscode then
    return
end

-- Neovim Options
vim.opt.number = true                    -- Show Line numbers
vim.opt.hidden = true                    -- Allow switching away from buffer without closing
vim.opt.wildmenu = true                 -- Better command-line completion
vim.opt.showcmd = true                  -- Show partial commands in the last line of the screen
vim.opt.hlsearch = true                 -- Highlight searches
vim.opt.updatetime = 300
vim.opt.backspace = {'indent','eol','start'} -- Allow backspacing over autoindent, line breaks and start of insert action
vim.opt.autoindent = true
vim.opt.startofline = false             -- Make j/k respect columns
vim.opt.confirm = true                  -- raise a dialogue asking if you wish to save changed files
vim.opt.visualbell = true               -- Use visual bell instead of beeping when doing something wrong
vim.opt.mouse = 'a'                     -- Enable use of the mouse for all modes
vim.opt.cmdheight = 2                   -- Set the command window height to 2 lines
vim.opt.swapfile = false                -- Disable swp files
vim.opt.compatible = false              -- Ignore vi compatability
vim.opt.spelllang = 'en_us'
vim.opt.spell = true

-- Enable filetype detection and plugins
vim.cmd('filetype on')
vim.cmd('filetype plugin on')

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
    -- Replace fzf.vim with fzf-lua
    {
      "ibhagwan/fzf-lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {},
    },
    
    {"nvim-tree/nvim-tree.lua", priority = 800},
    {"nvim-tree/nvim-web-devicons", opt = true}, -- optional, for file icons
    {"itchyny/lightline.vim"},
    {"preservim/nerdcommenter"},
    {"tpope/vim-sleuth"},
    {"christoomey/vim-tmux-navigator"},
    {"Mofiqul/vscode.nvim", priority = 1000},
    {
      "nvim-treesitter/nvim-treesitter", 
      build = ":TSUpdate",
      priority = 1000,
    },
  },
  install = { colorscheme = { "vscode" } },
  checker = { 
    enabled = true,     -- Keep the checker enabled
    frequency = 604800, -- Check once a week (in seconds: 7 * 24 * 60 * 60 = 604800)
    notify = false,     -- Don't display notifications
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Color scheme
if vim.fn.has('termguicolors') == 1 then
    vim.opt.termguicolors = true
end

-- Set up VSCode theme
vim.o.background = 'dark' -- Use dark theme
require('vscode').setup({
    -- Enable transparent background
    transparent = false,
    -- Enable italic comments
    italic_comments = true,
    -- Disable nvim-tree background color
    disable_nvimtree_bg = true,
    -- Apply theme colors to terminal
    terminal_colors = true
})

-- Load the theme
vim.cmd.colorscheme "vscode"

-- nvim-tree configuration
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
  },
  git = {
    enable = true,
  },
  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },
})

-- nvim-tree keymaps
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>')
vim.keymap.set('n', '<leader>nf', ':NvimTreeFindFile<CR>')

-- Treesitter configuration
require('nvim-treesitter.configs').setup {
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = { 
    -- Languages you commonly use
    "python", 
    "javascript", 
    "typescript", 
    "bash",
    "gitcommit",
    
    -- Important for Neovim itself
    "c", 
    "lua", 
    "vim", 
    "vimdoc", 
    "query", 
    "markdown", 
    "markdown_inline" 
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  
  -- Automatically install missing parsers when entering buffer
  auto_install = true,
  
  -- List of parsers to ignore installing (or "all")
  ignore_install = { },

  highlight = {
    enable = true,
    
    -- Disable slow treesitter highlight for large files
    disable = function(lang, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true
  },
}

-- fzf-lua keymaps
vim.keymap.set('n', '<C-p>', function() require('fzf-lua').files() end, { silent = true, desc = "FzfLua files" })
vim.keymap.set('n', '<C-b>', function() require('fzf-lua').buffers() end, { silent = true, desc = "FzfLua buffers" })

-- lightline
vim.g.lightline = {
    colorscheme = 'vscode'
}
