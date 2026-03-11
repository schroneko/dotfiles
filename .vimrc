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

let s:dotfiles_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:mise_shims = expand('~/.local/share/mise/shims')
if isdirectory(s:mise_shims) && index(split($PATH, ':'), s:mise_shims) < 0
    let $PATH = s:mise_shims . ':' . $PATH
endif

function! s:resolve_executable(name) abort
    let l:candidates = [
                \ exepath(a:name),
                \ expand('~/.local/share/mise/shims/' . a:name),
                \ expand('~/.volta/bin/' . a:name),
                \ '/opt/homebrew/bin/' . a:name,
                \ '/usr/local/bin/' . a:name,
                \ ]

    for l:candidate in l:candidates
        if !empty(l:candidate) && executable(l:candidate)
            return l:candidate
        endif
    endfor

    return a:name
endfunction

let s:npx = s:resolve_executable('npx')
let s:textlint_config = s:dotfiles_dir . '/.textlintrc.json'
let s:textlint_cmd = shellescape(s:npx)
            \ . ' --yes'
            \ . ' --package textlint'
            \ . ' --package textlint-rule-ja-space-between-half-and-full-width'
            \ . ' --package textlint-rule-no-space-between-full-width'
            \ . ' textlint'

function! RunFormatAndFix()
    let l:view = winsaveview()
    let l:ext = expand('%:e')
    let l:tempfile = tempname() . '.' . l:ext

    try
        call writefile(getline(1, '$'), l:tempfile)

        let l:cmd_oxfmt = shellescape(s:npx) . ' oxfmt ' . shellescape(l:tempfile)
        let l:oxfmt_output = system(l:cmd_oxfmt)

        if v:shell_error != 0
            if l:oxfmt_output =~ 'Expected at least one target file'
                echo "oxfmt: skipped (unsupported file type)"
                return
            endif
            echoerr "oxfmt failed! " . l:oxfmt_output
            return
        endif

        echo "oxfmt: OK... "

        " textlint (markdown のみ)
        if &filetype == 'markdown'
            let l:cmd_textlint = s:textlint_cmd
                        \ . ' --config ' . shellescape(s:textlint_config)
                        \ . ' --fix '
                        \ . shellescape(l:tempfile)
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

let &makeprg = fnameescape(s:npx) . ' oxlint --type-aware %'
set errorformat=%f:%l:%c:\ %m
command! Lint silent make | redraw! | copen
