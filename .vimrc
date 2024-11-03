" Install vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Check Prettier 
if !executable('prettier')
  echohl WarningMsg
  echom "Warning: Prettier is not installed. Please install it using 'npm install -g prettier' or 'volta install prettier'."
  echohl None
endif

" Plugin and Filetype Settings
filetype plugin on
call plug#begin()
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'ryanoasis/vim-devicons'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ggml-org/llama.vim'
call plug#end()

" Key Mappings
inoremap jj <ESC>
nmap ; :
nnoremap <Esc><Esc> :nohlsearch<Enter>
nnoremap <C-n> :Prettier<Enter>
nnoremap <C-p> :MarkdownPreview<Enter>

" Search Settings
set hlsearch
set ignorecase
set incsearch
set re=0
set shortmess-=S
set wrapscan

" Visual Settings
set number
set ambiwidth=double
set cursorline
set laststatus=0
set ruler
set visualbell
set whichwrap=h,l
set wildignorecase
set wildmenu
set wildmode=longest:full,full

" Editor Behavior
set autoindent
set autoread
set backspace=indent,eol,start
set expandtab
set nobackup
set noswapfile
set path+=**
set showmatch
set smartindent
set softtabstop=4
set tabstop=4
set virtualedit=onemore

" Indentation Settings
set shiftwidth=4

" Clipboard and UI Settings
set clipboard+=unnamed
set viminfo=

" Syntax Highlighting
syntax on

" Load All Plugins
packloadall

" Python Linting
let g:syntastic_python_pycodestyle_args='--ignore=E501'

" Custom Commands
command! -nargs=0 Prettier :CocCommand prettier.forceFormatDocument
command! -nargs=0 MarkdownPreview :call CocAction('runCommand', 'markdown-preview-enhanced.openPreview')
