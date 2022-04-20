set autoindent
set autoread
set backspace=indent,eol,start
set clipboard+=unnamed
set expandtab
set hlsearch
set incsearch
set laststatus=2
set nobackup
set nolist
set noswapfile
set path+=**
set ruler
set shiftwidth=2
set showcmd
set showmatch
set smartindent
set tabstop=2
set virtualedit=onemore
set visualbell
set whichwrap=h,l
set wildignorecase
set wildmenu
set wildmode=longest:full,full
set wrapscan
set relativenumber
set viminfo=

autocmd! bufwritepost $MYVIMRC source %
filetype plugin indent on
inoremap <silent> jj <ESC>
nnoremap gp :silent %!prettier --stdin-filepath %<CR>
syntax on
