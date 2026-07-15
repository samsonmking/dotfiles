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

vim.opt.ignorecase = true -- Use case insensitive search
vim.opt.smartcase = true -- Except when using capital letters
vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 10 -- Quickly time out on keycodes, but never time out on mappings

-- Neovim Options
vim.opt.number = true -- Show Line numbers
vim.opt.hidden = true -- Allow switching away from buffer without closing
vim.opt.wildmenu = true -- Better command-line completion
vim.opt.showcmd = true -- Show partial commands in the last line of the screen
vim.opt.hlsearch = true -- Highlight searches
vim.opt.updatetime = 300
vim.opt.backspace = { "indent", "eol", "start" } -- Allow backspacing over autoindent, line breaks and start of insert action
vim.opt.autoindent = true
vim.opt.startofline = false -- Make j/k respect columns
vim.opt.confirm = true -- raise a dialogue asking if you wish to save changed files
vim.opt.visualbell = true -- Use visual bell instead of beeping when doing something wrong
vim.opt.mouse = "a" -- Enable use of the mouse for all modes
vim.opt.cmdheight = 2 -- Set the command window height to 2 lines
vim.opt.swapfile = false -- Disable swp files
vim.opt.compatible = false -- Ignore vi compatability
vim.opt.spelllang = "en_us"
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
    ["+"] = function()
      return vim.split(vim.fn.getreg('"'), "\n")
    end,
    ["*"] = function()
      return vim.split(vim.fn.getreg('"'), "\n")
    end,
  },
}
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

-- Yank the current file's path (relative to cwd) to the system clipboard
vim.keymap.set("n", "<leader>yp", function()
  local path = vim.fn.expand("%:.")
  vim.fn.setreg("+", path)
  vim.notify('Yanked "' .. path .. '"')
end, { desc = "Yank current file path" })

-- Enable filetype detection and plugins
vim.cmd("filetype on")
vim.cmd("filetype plugin on")

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  checker = {
    enabled = true,
    frequency = 604800,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
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
if vim.fn.has("termguicolors") == 1 then
  vim.opt.termguicolors = true
end

vim.cmd("colorscheme onedark")
