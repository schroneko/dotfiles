autocmd! bufwritepost ~/.vimrc source %
filetype plugin indent on
inoremap jj <Esc>
nmap <Esc><Esc> :nohlsearch<CR><Esc>
nnoremap gp :silent %!prettier --stdin-filepath %<CR>
set autoindent
set autoread
set backspace=indent,eol,start
set expandtab
set hlsearch
set incsearch
set laststatus=2
set nobackup
set nolist
set noswapfile
set ruler
set shiftwidth=2
set showcmd
set showmatch
set smartindent
set tabstop=2
set virtualedit=onemore
set visualbell
set whichwrap=h,l
set wrapscan
syntax on
