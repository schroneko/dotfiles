set fenc=utf-8
set nobackup
set noswapfile
set autoread
set showcmd
set virtualedit=onemore
set smartindent
set autoindent
set visualbell
set showmatch
set laststatus=2
set wildmode=list:longest
set expandtab
set tabstop=2
set shiftwidth=2
set ignorecase
set wrapscan
set title
set list
set ruler
set listchars=eol:↲
set whichwrap=h,l
set backspace=indent,eol,start
set incsearch
set hlsearch
nmap <Esc><Esc> :nohlsearch<CR><Esc>
syntax enable
filetype plugin indent on
autocmd BufWritePre * :%s/\s\+$//ge
inoremap jj <Esc>

