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
    { "junegunn/fzf", build = "./install --bin" },
    {"junegunn/fzf.vim"},
    {"preservim/nerdtree"},
    {"itchyny/lightline.vim"},
    {"preservim/nerdcommenter"},
    {"tpope/vim-sleuth"},
    {"christoomey/vim-tmux-navigator"},
    {"navarasu/onedark.nvim", name = "onedark", priority = 1000}
  },
  install = { colorscheme = { "onedark" } },
  checker = { enabled = true },
})

-- Color scheme
if vim.fn.has('termguicolors') == 1 then
    vim.opt.termguicolors = true
end
vim.cmd.colorscheme "onedark"
require('onedark').setup {
    style = 'darker'
}
require('onedark').load()

-- fzf options
-- exclude files in .gitignore from fzf
vim.env.FZF_DEFAULT_COMMAND = 'rg --files'
-- map C-p to fzf file search
vim.keymap.set('n', '<C-p>', ':Files<CR>')

-- NERDTree
-- Toggle NERDTree with Ctrl+n
vim.keymap.set('n', '<C-n>', ':NERDTreeToggle<CR>')

-- lightline
vim.g.lightline = {
    colorscheme = 'catppuccin'
}
