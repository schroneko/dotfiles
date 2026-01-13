set number
set cursorline
set clipboard+=unnamed
set laststatus=0
set cmdheight=0
set title
set titlestring=%t
set shortmess+=F
set noshowcmd
set noshowmode
set signcolumn=no
set autoread
set nobackup
set noswapfile
set backspace=indent,eol,start
set whichwrap=h,l

syntax on
filetype plugin indent on
set hlsearch
set incsearch
set ignorecase
set smartcase
set autoindent
set expandtab
set tabstop=4
set shiftwidth=4
set ambiwidth=double
set wildmenu
set wildmode=longest:full,full

autocmd FileType javascript,typescript,json,yaml setlocal tabstop=2 shiftwidth=2

inoremap jj <ESC>
nnoremap <Esc><Esc> :nohlsearch<Enter>
nnoremap ;; :
cnoreabbrev %y silent %y

function! RunFormatAndFix()
    let l:view = winsaveview()
    let l:ext = expand('%:e')
    let l:tempfile = tempname() . '.' . l:ext

    try
        call writefile(getline(1, '$'), l:tempfile)

        let l:cmd_oxfmt = 'npm exec oxfmt -- ' . shellescape(l:tempfile)
        let l:oxfmt_output = system(l:cmd_oxfmt)

        if v:shell_error != 0
            echoerr "oxfmt failed! " . l:oxfmt_output
            return
        endif

        echo "oxfmt: OK... "

        " textlint (markdown のみ)
        if &filetype == 'markdown'
            let l:cmd_textlint = 'textlint --config ~/.claude/.textlintrc --fix ' . shellescape(l:tempfile)
            let l:textlint_output = system(l:cmd_textlint)
            let l:textlint_exit = v:shell_error

            if l:textlint_exit == 2
                echoerr "textlint error! " . l:textlint_output
                return
            elseif l:textlint_exit == 1
                echo "Formatted & Fixed (Issues remain) ⚠️"
            else
                echo "Formatted & Fixed (Perfect) ✨"
            endif
        else
            echo "Formatted (oxfmt) ✨"
        endif

        let l:final_lines = readfile(l:tempfile)
        let l:current_lines = getline(1, '$')

        if l:final_lines != l:current_lines
            silent %delete _
            call setline(1, l:final_lines)
        endif
        call winrestview(l:view)
        redraw
    finally
        call delete(l:tempfile)
    endtry
endfunction

nnoremap <C-=> :call RunFormatAndFix()<CR>

set makeprg=npx\ oxlint\ --type-aware\ %
set errorformat=%f:%l:%c:\ %m
command! Lint silent make | redraw! | copen
