-- Disable netrw for nvim-tree vim.g.loaded_netrw = 1 vim.g.loaded_netrwPlugin = 1

-- Source per-project .nvim.lua files
vim.o.exrc = true

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

-- Yank to system clipboard via OSC52 (forwarded by tmux → Ghostty → host).
-- Paste is intentionally not wired through OSC52: tmux intercepts OSC52 reads
-- and returns its own buffer instead of forwarding to the outer terminal,
-- so `p` would return stale data. Use ⌘V/Ctrl-V in insert mode to paste from
-- the host clipboard — that goes through bracketed paste, which works everywhere.
vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = function() return vim.split(vim.fn.getreg('"'), "\n") end,
    ["*"] = function() return vim.split(vim.fn.getreg('"'), "\n") end,
  },
}
-- Defer 'clipboard' until after UiEnter to avoid blocking startup on the
-- provider. See kickstart.nvim and `:help 'clipboard'`.
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

-- Enable filetype detection and plugins
vim.cmd('filetype on')
vim.cmd('filetype plugin on')

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
    -- Install fzf binary via plugin (package manager version may be too old for fzf-lua)
    { "junegunn/fzf", build = "./install --bin" },
    -- Replace fzf.vim with fzf-lua
    {
      "ibhagwan/fzf-lua",
      dependencies = { "nvim-tree/nvim-web-devicons", "junegunn/fzf" },
      opts = {
        fzf_bin = vim.fn.stdpath("data") .. "/lazy/fzf/bin/fzf",
      },
    },

    {"nvim-tree/nvim-tree.lua", priority = 800},
    {"nvim-tree/nvim-web-devicons", opt = true}, -- optional, for file icons
    {"itchyny/lightline.vim"},
    {"preservim/nerdcommenter"},
    {"tpope/vim-sleuth"},
    {"christoomey/vim-tmux-navigator"},
    {
      "olimorris/onedarkpro.nvim",
      priority = 1000, -- Ensure it loads first
    },
    {
      'MeanderingProgrammer/render-markdown.nvim',
      dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
      ---@module 'render-markdown'
      ---@type render.md.UserConfig
      opts = {},
    },

    -- Git
    {
      "lewis6991/gitsigns.nvim",
      opts = {
        on_attach = function(bufnr)
          vim.keymap.set('n', '<leader>hd', require('gitsigns').preview_hunk_inline,
            { buffer = bufnr, desc = 'Preview hunk inline' })
          vim.keymap.set('n', '<leader>hr', require('gitsigns').reset_hunk,
            { buffer = bufnr, desc = 'Reset hunk' })
        end,
      },
    },

    -- LSP
    { "neovim/nvim-lspconfig" },
    { "mason-org/mason.nvim", opts = {} },
    { "mason-org/mason-lspconfig.nvim" },

    -- Formatting
    { "stevearc/conform.nvim" },

    -- Completion
    {
      'saghen/blink.cmp',
      version = '1.*',
      opts = {
        enabled = function()
          local disabled = { markdown = true, gitcommit = true }
          return not disabled[vim.bo.filetype]
        end,
        keymap = { preset = 'default' },
        completion = {
          documentation = { auto_show = true },
        },
        sources = {
          default = { 'lsp', 'path', 'buffer' },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
      },
    },
  },
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

vim.cmd("colorscheme onedark_dark")

-- fzf-lua configuration
vim.api.nvim_set_keymap("n", "<C-\\>", [[<Cmd>lua require"fzf-lua".buffers()<CR>]], {})
vim.api.nvim_set_keymap("n", "<C-p>", [[<Cmd>lua require"fzf-lua".files()<CR>]], {})
vim.api.nvim_set_keymap("n", "<C-g>", [[<Cmd>lua require"fzf-lua".live_grep_native()<CR>]], {})
vim.keymap.set({ "i" }, "<C-x><C-f>",
function()
  FzfLua.complete_file({
    winopts = { preview = { hidden = true } }
  })
end, { silent = true, desc = "Fuzzy complete file" })
vim.keymap.set({ "i" }, "<C-x><C-g>",
function()
  FzfLua.git_commits({
    winopts = { preview = { hidden = true } },
    complete = function(selected, _, line, col)
      local hash = selected[1]:match("[^ ]+")
      local after = #line > col and line:sub(col + 1) or ""
      return line:sub(1, col) .. hash .. after, col + #hash
    end,
    actions = {
      ["enter"] = require("fzf-lua.actions").complete,
    },
  })
end, { silent = true, desc = "Fuzzy insert git commit hash" })
vim.keymap.set({ "i" }, "<C-x><C-a>",
function()
  FzfLua.complete_file({
    winopts = { preview = { hidden = true } },
    actions = {
      ["enter"] = function(selected, opts)
        if not selected[1] then
          if opts.__CTX and opts.__CTX.mode == "i" then
            vim.cmd [[noautocmd lua vim.api.nvim_feedkeys('i', 'n', true)]]
          end
          return
        end
        local orig_complete = opts.complete
        opts.complete = function(sel, o, l, c)
          local newline, newcol = orig_complete(sel, o, l, c)
          if not newline then return end
          local match_pat = opts.word_pattern or "[^%s\"']*"
          local before = c > 1
          and (l:sub(1, c - 1):reverse():match(match_pat) or ""):reverse()
          or ""
          local path_start = c - #before - 1
          return newline:sub(1, path_start) .. "@" .. newline:sub(path_start + 1),
          newcol + 1
        end
        require("fzf-lua.actions").complete(selected, opts)
      end,
    },
  })
end, { silent = true, desc = "Fuzzy complete @file" })

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

-- LSP configuration
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright" },
})
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})
local pyright_root = vim.fs.root(0, {"pyproject.toml", "pyrightconfig.json", ".git"}) or vim.fn.getcwd()
vim.lsp.config('pyright', {
  root_markers = { "pyproject.toml", "pyrightconfig.json", ".git" },
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "off",
        extraPaths = { pyright_root },
      },
    },
  },
})
vim.lsp.enable('pyright')

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
    map('gd', vim.lsp.buf.definition, 'Go to definition')
    map('gD', vim.lsp.buf.declaration, 'Go to declaration')
    map('<leader>e', vim.diagnostic.open_float, 'Show diagnostics')
  end,
})

-- Formatting
require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    if vim.bo[bufnr].filetype == 'python' then
      return { timeout_ms = 500 }
    end
  end,
  default_format_opts = {
    lsp_format = 'fallback',
  },
  formatters_by_ft = {
    python = { "ruff_organize_imports", "black" },
  },
}

vim.keymap.set("n", "<leader>f", function()
  require('conform').format({ async = true })
end, { desc = "Format buffer" })


-- lightline
vim.g.lightline = {
  colorscheme = 'one'
}
