set nobackup
set number
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

" 矢印キーでなら行内を動けるように
nnoremap <Down> gj
nnoremap <Up>   gk

" 日本語入力がオンのままでも使えるコマンド(Enterキーは必要)
nnoremap あ a
nnoremap い i
nnoremap う u
nnoremap お o
nnoremap っd dd
nnoremap っy yy

" jjでエスケープ
inoremap <silent> jj <ESC>

" 日本語入力で”っj”と入力してもEnterキーで確定させればインサートモードを抜ける
inoremap <silent> っj <ESC>

augroup vimrc-auto-mkdir  " {{{
  autocmd!
  autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
  function! s:auto_mkdir(dir, force)  " {{{
    if !isdirectory(a:dir) && (a:force ||
    \    input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
      call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
    endif
  endfunction  " }}}
augroup END  " }}}


" [markdown] configure formatprg
autocmd FileType markdown set formatprg=prettier\ --parser\ markdown
autocmd FileType javascript set formatprg=prettier\ --parser\ javascript

" [markdown] format on save
" autocmd! BufWritePre *.md call s:mdfmt()
autocmd! BufWritePre *.md, *.js call s:mdfmt()
function s:mdfmt()
    let l:curw = winsaveview()
    silent! exe "normal! a \<bs>\<esc>" | undojoin |
        \ exe "normal gggqG"
    call winrestview(l:curw)
endfunction

" auto reload .vimrc
autocmd! bufwritepost ~/.vimrc source %

" auto Prettier
" augroup fmt
" autocmd!
" autocmd BufWritePre,TextChanged,InsertLeave *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.svelte,*.yaml,*.html PrettierAsync
" augroup END
