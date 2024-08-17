" Install vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugin and Filetype Settings
filetype plugin on
call plug#begin()
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-commentary'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
call plug#end()

" Key Mappings
inoremap jj <ESC>
nmap ; :
nnoremap <Esc><Esc> :nohlsearch<Enter>
nnoremap <C-n> :Prettier<Enter>
" nnoremap <C-a> :NERDTreeToggle<CR>
" nnoremap <C-p> <Plug>AirlineSelectPrevTab
" nnoremap <C-n> <Plug>AirlineSelectNextTab
nnoremap <C-p> :MarkdownPreview<Enter>

let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#tabline#buffer_idx_format = {
	\ '0': '0 ',
	\ '1': '1 ',
	\ '2': '2 ',
	\ '3': '3 ',
	\ '4': '4 ',
	\ '5': '5 ',
	\ '6': '6 ',
	\ '7': '7 ',
	\ '8': '8 ',
	\ '9': '9 '
	\}

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

" Custom Commands
command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')
command! -nargs=0 MarkdownPreview :call CocAction('runCommand', 'markdown-preview-enhanced.openPreview')
