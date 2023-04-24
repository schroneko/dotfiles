" Keybind
inoremap jj <ESC>
nmap ; :
nnoremap <C-e> :ALEFix<CR>
nnoremap <C-p> :MarkdownPreviewToggle<CR>
nnoremap <C-n> :Lexplore<CR>

nnoremap <Esc><Esc> :nohlsearch<Enter>

" Plugins
filetype plugin on
packloadall " Load all plugins

" Customize
command! CPT let @+ = expand('%') | echo "File name copied to clipboard"

" Zenkaku to full width
set ambiwidth=double

" Netrw
let g:netrw_banner=0
let g:netrw_browse_split=4
let g:netrw_altv=1
let g:netrw_liststyle=3
let g:netrw_winsize=25

" let g:rustfmt_autosave = 1
set cursorline
set number
set autoindent " Auto indent
set autoread " Auto reload file when changed
set ambiwidth=double
set backspace=indent,eol,start " Backspace to delete
set clipboard+=unnamed " Copy to system clipboard
set expandtab " Use spaces instead of tabs
set hlsearch " Highlight search
set incsearch " Incremental search
set ignorecase
set laststatus=0 " Always show status line
set nobackup " Don't create backup files
set shortmess-=S " Don't show search messages
set noswapfile " Don't create swap files
set path+=**  " Search files recursively
set ruler " Show cursor position
set shiftwidth=4 " Shift width
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

let g:ale_fixers = {
  \   'markdown': ['prettier'],
  \   'javascript': ['prettier'],
  \   'html': ['prettier'],
  \   'css': ['prettier'],
  \   'json': ['prettier'],
  \   'yaml': ['prettier'],
  \   'typescript': ['prettier', 'tslint'], 
\}

" vim-plug
call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'dense-analysis/ale'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

call plug#end()
