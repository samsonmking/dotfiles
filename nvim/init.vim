" VSCode + Neovim Options
"-------------------------------------------------------------
set ignorecase                          " Use case insensitive search
set smartcase                           " Except when using capital letters
set notimeout ttimeout ttimeoutlen=10   " Quickly time out on keycodes, but never time out on mappings

if exists('g:vscode')
    finish
endif

" Neovim Options
"-------------------------------------------------------------
set number                              " Show Line numbers
set hidden                              " Allow switching away from buffer without closing
set wildmenu                            " Better command-line completion
set showcmd                             " Show partial commands in the last line of the screen
set hlsearch                            " Highlight searches
set updatetime=300
set backspace=indent,eol,start          " Allow backspacing over autoindent, line breaks and start of insert action
set autoindent
set nostartofline                       " Make j/k respect columns
set confirm                             " raise a dialogue asking if you wish to save changed files.
set visualbell                          " Use visual bell instead of beeping when doing something wrong
set t_vb=                               " If visualbell is set, vim will neither flash nor beep. If visualbell
set mouse=a                             " Enable use of the mouse for all modes
set cmdheight=2                         " Set the command window height to 2 lines
set pastetoggle=<F11>                   " Use <F11> to toggle between 'paste' and 'nopaste'
set noswapfile                          " Disable swp files
set nocompatible                        " Ignore vi compatability
filetype on                             " Filetype specific logic
filetype plugin on

" Bootstrap Vim-plug
"-------------------------------------------------------------
let autoload_plug_path = stdpath('data') . '/site/autoload/plug.vim'
if !filereadable(autoload_plug_path)
  silent execute '!curl -fLo ' . autoload_plug_path . '  --create-dirs 
      \ "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
unlet autoload_plug_path

" Vim-plug
"-------------------------------------------------------------
call plug#begin(stdpath('config').'/plugged')

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'navarasu/onedark.nvim'
Plug 'preservim/nerdtree'
Plug 'itchyny/lightline.vim'
Plug 'dense-analysis/ale'
Plug 'preservim/nerdcommenter'
Plug 'tpope/vim-sleuth'

call plug#end()

" Color scheme
"-------------------------------------------------------------
if has('termguicolors')
  set termguicolors
endif
let g:onedark_style = 'darker'
colorscheme onedark 

"  fzf options
" ------------------------------------------------------------
" exclude files in .gitignore from fzf
let FZF_DEFAULT_COMMAND='rg --files'
" map C-p to fzf file search
nnoremap <C-p> :Files<CR>

" NERDTree
"-------------------------------------------------------------
" Toggle NERDTree with Ctrl+n
map <C-n> :NERDTreeToggle<CR>

" ALE
"-------------------------------------------------------------
let g:ale_fixers = {
\ 'javascript': ['prettier'],
\ 'css': ['prettier'],
\ 'html': ['prettier'],
\ 'markdown': ['prettier'],
\ 'python': ['autopep8', 'isort']
\}
let g:ale_linters = {
\ 'python': ['pylint']
\}
let g:ale_python_pylint_options = '--load-plugins pylint_django'
let g:ale_linters_explicit = 1
let g:ale_fix_on_save = 1

" treesitter
"-------------------------------------------------------------
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true,              -- false will disable the whole extension
    additional_vim_regex_highlighting = false,
  },
}
EOF

" lightline
"-------------------------------------------------------------
let g:lightline = {
\ 'colorscheme': 'one',
\ }
