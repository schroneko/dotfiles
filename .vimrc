filetype plugin on
inoremap jj <ESC>
nmap ; :
nnoremap <Esc><Esc> :nohlsearch<Enter>
packloadall " Load all plugins
set ambiwidth=double
set autoindent " Auto indent
set autoread " Auto reload file when changed
set backspace=indent,eol,start " Backspace to delete
set clipboard+=unnamed " Copy to system clipboard
set cursorline
set expandtab " Use spaces instead of tabs
set hlsearch " Highlight search
set ignorecase
set incsearch " Incremental search
set laststatus=0 " Always show status line
set nobackup " Don't create backup files
set noswapfile " Don't create swap files
set number
set path+=**  " Search files recursively
set re=0
set ruler " Show cursor position
set shiftwidth=4 " Shift width
set shortmess-=S " Don't show search messages
set showmatch " Show matching brackets
set smartindent " Smart indent (indent after new line)
set softtabstop=4
set tabstop=4
set viminfo= 
set virtualedit=onemore
set visualbell
set whichwrap=h,l
set wildignorecase
set wildmenu
set wildmode=longest:full,full
set wrapscan
syntax on

call plug#begin()
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
call plug#end()

command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')
nnoremap <C-n> :Prettier<Enter>
nnoremap <C-p> :MarkdownPreview<Enter>
