" Plugin and Filetype Settings
filetype plugin on
call plug#begin()
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
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

" Custom Commands
command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')
