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

-- Bootstrap Vim-plug
local install_path = vim.fn.stdpath('data') .. '/site/autoload/plug.vim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({
        'curl', '-fLo', install_path, '--create-dirs',
        'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    })
    vim.cmd('autocmd VimEnter * PlugInstall --sync | source $MYVIMRC')
end

-- Vim-plug
vim.cmd([[
call plug#begin(stdpath('config').'/plugged')

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'
Plug 'itchyny/lightline.vim'
Plug 'preservim/nerdcommenter'
Plug 'tpope/vim-sleuth'
Plug 'christoomey/vim-tmux-navigator'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }

call plug#end()
]])

-- Color scheme
if vim.fn.has('termguicolors') == 1 then
    vim.opt.termguicolors = true
end
vim.cmd('colorscheme catppuccin-mocha')

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
