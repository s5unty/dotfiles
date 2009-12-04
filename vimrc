" General {{{
let &termencoding=&encoding
set fileencodings=UTF-8,GB2312,BIG5
set fileformats=unix,dos
set statusline=%<%f\ \[%{&fileencoding}\]\ %h%m%r%=%-14.(%l,%c%V%)\ %P
set mouse=a " 开启鼠标支持
"set guifont=Courier\ 10\ Pitch\ 14
set tabstop=4 " 缩进的宽度
set shiftwidth=4 " TAB 的宽度
set clipboard+=unnamed " 选入剪贴板
set backspace=indent,eol,start " 退格
set foldmethod=marker
set pastetoggle=<F4>
set ignorecase " 搜索忽略大小写
set autoindent " 自动缩进
set number " 显示行数
set completeopt=longest,menu
set smartcase
syn on " 语法高亮
filetype plugin indent on
let mapleader=","
set noswapfile
set nocompatible
set nohls " 不高亮匹配关键字
set noincsearch " 非渐进搜索
set noexpandtab " ! TAB -> SPACE
set nowrap " 不自动折行
set updatetime=200
" }}}

" Function {{{
" 自定义 QuickFix 全局变量
" @forced:
"   1 always show qfix
"   0 always hide qfix
"  -1 switch show/hide
function G_QFixToggle(forced)
    if exists("g:qfix_win")
        if a:forced == 1
            return
        endif

        cclose
        unlet g:qfix_win
    else
        if a:forced == 0
            return
        endif

        copen 11
        let g:qfix_win = bufnr("$")
    endif
endfunction

" 快速在 QuickFix, Editor 窗口间切换:
function G_GoodSpace(browse)
    if a:browse == 1
        " 保留空格键打开折叠
        if foldtextresult(line('.')) != ""
            normal zv
        else
            exec "normal \<C-D>"
        endif

        return
    endif

    " 与 Quickfix 交换焦点窗口
    if &buftype == "quickfix"
        wincmd k
    elseif &buftype == "nofile"
        wincmd b
    elseif &buftype == ""
        if exists("g:qfix_win")
            wincmd b
        else
            wincmd h
        endif
    endif
endfunction

function G_Good_p()
    if &buftype == "quickfix"
        exec "normal \<Return>"
        exec "set cursorline"
        normal zz
        wincmd w
    else
        nunmap p
        normal "*p
        nnor <silent> <unique> p :call G_Good_p()<CR>
    endif
endfunction

" 跳转至文件编辑窗口
function G_GotoEditor()
    " 禁用 Quickfix 作为编辑窗口
    if &buftype == "quickfix"
        wincmd w
    " 禁用 __Tag_List__ 作为编辑窗口
    elseif bufname("%") == "__Tag_List__"
        wincmd l
    " 禁用 nofile buf 作为编辑窗口
    elseif &buftype == "nofile"
        wincmd w
    " 禁用 mini buf 作为编辑窗口
    elseif bufname("%") == "-TabBar-"
        wincmd w
    " 正确的编辑窗口
    elseif &buftype == ""
        return
    else
        return
    endif

    call G_GotoEditor()
endfunction
" }}}

" Key bindings {{{
nmap <silent> <unique> <F1> :set cursorline!<CR>:set nocursorline?<CR>
imap <silent> <unique> <F1> <ESC>:set cursorline!<CR><ESC>:set nocursorline?<CR>a
nmap <silent> <unique> <F2> :set nowrap!<CR>:set nowrap?<CR>
imap <silent> <unique> <F2> <ESC>:set nowrap!<CR>:set nowrap?<CR>a
nmap <silent> <unique> <F3> :set nohls!<CR>:set nohls?<CR>
imap <silent> <unique> <F3> <ESC>:set nohls!<CR>:set nohls?<CR>a
nmap <silent> <unique> <F4> :set nopaste!<CR>:set nopaste?<CR>
imap <silent> <unique> <F4> <ESC>:set nopaste!<CR>:set nopaste?<CR>a

nmap <silent> <unique> <F8> :wa!<CR>:make<CR>:call G_QFixToggle(1)<CR>
imap <silent> <unique> <F8> <ESC>:wa!<CR>:make<CR>:call G_QFixToggle(1)<CR>
nmap <silent> <unique> <F9> :!!<CR>
imap <silent> <unique> <F9> <ESC>:!!<CR>

nmap <silent> <unique> <F11> g]
nmap <silent> <unique> <F12> <C-]>
nmap <silent> <unique> \     <C-I>
nmap <silent> <unique> <Backspace> <C-O>
nmap <silent> <unique> - <C-U>
nmap <silent> <unique> = 10[{zz
nmap <silent> <unique> ; zz
nmap <silent> <unique> W :exec "%s /\\s\\+$//ge"<CR>:w<CR>
nmap <silent> <unique> q :call G_QFixToggle(-1)<CR>
nmap          <unique> t <ESC>:!
nnor <silent> <unique> y "*y
nnor <silent> <unique> d "*d
nnor <silent> <unique> p :call G_Good_p()<CR>
nmap <silent> <unique> <SPACE> :call G_GoodSpace(1)<CR>
nmap <silent> <unique> <ESC><SPACE> :call G_GoodSpace(0)<CR>
nmap <silent> <unique> <ESC><TAB> :pclose<CR>:set cursorline<CR><C-W>}:set nocursorline<CR>
nmap <silent> <unique> <ESC>m :marks ABC<CR>
nmap <silent> <unique> <ESC>` :e #<CR>
imap <silent> <unique> <ESC>` <ESC>:e #<CR>
nmap <silent> <unique> <ESC>q :pclose<CR>
nmap <silent> <unique> <C-Q> :qa!<CR>
nmap <silent> <unique> <leader>f 10[{zf%
nmap <silent> <unique> <leader>1 :.diffget BASE<CR>:diffupdate<CR>
nmap <silent> <unique> <leader>2 :.diffget LOCAL<CR>:diffupdate<CR>
nmap <silent> <unique> <leader>3 :.diffget REMOTE<CR>:diffupdate<CR>

imap <silent> <unique> <ESC><SPACE> <ESC>:<CR>
imap <silent> <unique> <ESC>f <C-O>w
imap <silent> <unique> <ESC>b <C-O>b
imap <silent> <unique> <ESC>e <ESC>ea
imap <silent> <unique> <C-A> <C-O>I
imap <silent> <unique> <C-E> <C-O>A
imap <silent> <unique> <C-S> <ESC>:wa<CR>
" }}}

" Autocmd {{{
if has("autocmd")
  function <SID>AC_ResetCursorPosition()
      if line("'\"") > 0 && line("'\"") <= line("$")
          exec "normal g`\"zz"
      endif
  endfunction

  " 每次访问文件时都把光标放置在上次离开的位置
  autocmd BufReadPost *
    \ call <SID>AC_ResetCursorPosition()

  " 保存文件之前先删除行末的多余空格
  " autocmd BufWritePre *
  "   \ exec "%s /\\s\\+$//ge"

  " 让 checkpath 找到相关文件，便于 [I 正常工作
  autocmd BufEnter,WinEnter *.c,*.cc,*.cpp,*.cxx,*.h,*.hh,*.hpp
    \ set path+=./

endif
" }}}

" Plugins {{{
" mru.vim 3.2 : Plugin to manage Most Recently Used (MRU) files {{{
let MRU_Max_Entries=30
let MRU_Exclude_Files='^/tmp/.*\|^/var/tmp/.*'
let MRU_Include_Files='\.c$\|\.cpp$\|\.h$\|\.hpp$'  " For C Source
let MRU_Window_Height=15
let MRU_Add_Menu=0
nmap <silent> <unique> <F5> :MRU<CR>
if has("autocmd")
  autocmd BufReadPost,FileReadPost *
    \ chdir .
endif
" }}}

" taglist.vim : Source code browser (supports C/C++, java, perl, python, tcl, sql, php, etc) {{{
" http://www.vim.org/scripts/script.php?script_id=273
let Tlist_Ctags_Cmd = "/usr/bin/ctags-exuberant"
let Tlist_WinWidth=35
let Tlist_Show_One_File = 1
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_Use_Horiz_Window = 0
nmap <silent> <unique> <leader>l :call <SID>ShowTaglist()<CR>
function <SID>ShowTaglist()
    if exists("g:loaded_taglist")
        call G_GotoEditor()
        exec "TlistToggle"
        exec "TlistSync"
    endif
endfunction
" }}}

" TabBar-0.7 : Plugin to add tab bar (derived from miniBufExplorer) {{{
" http://www.vim.org/scripts/script.php?script_id=1338
nmap <silent> <unique> <ESC>n :call G_QFixToggle(0)<CR>:call G_GotoEditor()<CR>:bn!<CR>
nmap <silent> <unique> <ESC>p :call G_QFixToggle(0)<CR>:call G_GotoEditor()<CR>:bp!<CR>
nmap <silent> <unique> <ESC>d :call <SID>CloseBuffer()<CR>
function <SID>CloseBuffer()
    call G_QFixToggle(0)
    call G_GotoEditor()

    if exists("g:bufexplorer_version")
        exec "BufExplorer"
        normal d
        exec "normal \<CR>"
    endif
endfunction
" }}}

" bufexplorer.zip : Buffer Explorer / Browser {{{
" http://www.vim.org/scripts/script.php?script_id=42
let bufExplorerShowRelativePath = 0
nmap <silent> <unique> <leader>, :BufExplorer<CR>
" }}}

" SuperTab continued. : Do all your insert-mode completion with Tab. {{{
" http://www.vim.org/scripts/script.php?script_id=1643
let g:SuperTabRetainCompletionType=2
let g:SuperTabDefaultCompletionType="<C-X><C-U>"
" }}}

" Mark : a little script to highlight several words in different colors simultaneously {{{
" http://www.vim.org/scripts/script.php?script_id=1238
nnoremap <silent> <unique> mA :call <SID>G_Mark("A")<CR>
nnoremap <silent> <unique> mB :call <SID>G_Mark("B")<CR>
nnoremap <silent> <unique> mC :call <SID>G_Mark("C")<CR>
function <SID>G_Mark(bm)
    exec "mark ".a:bm
    normal V,m
endfunction
" }}}

" Cscope : Interactively examine a C program source {{{
set tag=cscope.tags,~/.tags;
if has("cscope")
    set csto=1
    set nocsverb
    set cspc=3
    set cscopequickfix=s-,c-,d-,i-,t-,e-

    autocmd BufNewFile,BufReadPost,FileReadPost *
      \ let &path = getcwd()."/*"

    " add any database in current directory
    if filereadable("cscope.out")
        cscope add cscope.out
        cscope reset
    " else add database pointed to by environment
    elseif $CSCOPE_DB != ""
        cscope add $CSCOPE_DB
        cscope reset
    endif

    " 在后台更新 tags | cscope*，便于在代码间正确的跳转
    autocmd BufWritePost,FileWritePost *.c,*.cc,*.cpp,*.cxx,*.h,*.hh,*.hpp
      \ call system("cscope -kbq &")|
      \ call system("ctags -e -u --c++-kinds=+p --fields=+iaS --extra=+q -Lcscope.files -fcscope.tags &")|
      \ exec "cscope add cscope.out"|
      \ exec "cscope reset"
endif

function <SID>CscopeFind(mask, quick)
    call G_QFixToggle(0)
    call G_GotoEditor()
    if a:quick == 'y'
        let str = expand('<cword>')
    elseif a:quick == 'n'
        let str = input('Search Pattern: ')
        if str == ""
            echo ""
            return
        endif
    endif
    let @/ = str
    normal mG
    exec ":cs find ".a:mask." ".str
    normal `G
    call G_QFixToggle(1)
endfunction
nmap <silent> <unique> <leader>s :call <SID>CscopeFind('s', 'y')<CR>
nmap <silent> <unique> <leader>c :call <SID>CscopeFind('c', 'y')<CR>
nmap <silent> <unique> <leader>g :call <SID>CscopeFind('e', 'y')<CR>
nmap <silent> <unique> <leader>d :call <SID>CscopeFind('d', 'y')<CR>
nmap <silent> <unique> <leader>S :call <SID>CscopeFind('s', 'n')<CR>
nmap <silent> <unique> <leader>C :call <SID>CscopeFind('c', 'n')<CR>
nmap <silent> <unique> <leader>G :call <SID>CscopeFind('e', 'n')<CR>
nmap <silent> <unique> <leader>D :call <SID>CscopeFind('d', 'n')<CR>
" }}}

" {{{ VimIM: Vim 中文输入法
" http://vimim.googlecode.com/svn/vimim/vimim.html
let g:vimim_shuangpin_microsoft=1
" }}}

" }}}

" Colour {{{
let g:colors_name="blue"

" First remove all existing highlighting.
hi clear
if exists("syntax_on")
  syntax reset
endif

set background=dark
" normal
hi Normal           ctermfg=darkyellow                      guifg=yellow guibg=#000066
hi SpecialKey       cterm=reverse
hi NonText          ctermfg=darkmagenta                     guifg=magenta
hi Directory        ctermfg=darkblue                        guifg=blue
hi ErrorMsg         ctermfg=red         ctermbg=none        guibg=red gui=bold
hi WarningMsg       ctermfg=yellow      ctermbg=none        guibg=yellow gui=bold
hi StatusLine       ctermfg=gray        ctermbg=black
hi MatchParen       ctermfg=white 		ctermbg=cyan 		guifg=white guibg=cyan
hi StatusLineNC     ctermfg=gray        ctermbg=black
hi IncSearch        ctermfg=darkyellow  ctermbg=darkblue
hi Search           ctermfg=darkyellow  ctermbg=darkblue
hi Question         ctermfg=gray                            guifg=gray
hi LineNr           ctermfg=darkgreen                       guifg=green
hi DiffAdd          ctermfg=darkgreen   ctermbg=none        guifg=green
hi DiffChange       ctermfg=blue        ctermbg=black       guifg=blue
hi DiffDelete       ctermfg=darkred     ctermbg=none        guifg=red
hi DiffText         ctermfg=yellow      ctermbg=none        guifg=yellow
hi Folded           ctermfg=darkyellow  ctermbg=none        guifg=yellow
hi FoldColumn       ctermfg=darkyellow  ctermbg=none        guifg=yellow
" dev
hi Comment          ctermfg=darkgreen                       guifg=green
hi Constant         ctermfg=gray                            guifg=gray
hi Special          ctermfg=darkred                         guifg=red
hi Identifier       ctermfg=darkblue                        guifg=blue
hi Statement        ctermfg=gray                            guifg=gray
hi Operator         ctermfg=darkblue                        guifg=blue
hi PreProc          ctermfg=darkmagenta                     guifg=magenta
hi Type             ctermfg=darkblue                        guifg=blue
hi Underlined       ctermfg=darkyellow  ctermbg=darkblue    guifg=yellow guibg=blue
hi Ignore           ctermfg=darkgrey    ctermbg=yellow      guifg=grey guibg=yellow
hi Error            ctermfg=white       ctermbg=red         guifg=white guibg=red
hi Todo             ctermfg=white       ctermbg=green       guifg=white guibg=green
hi String           ctermfg=darkcyan 						guifg=cyan
hi Number           ctermfg=darkmagenta                     guifg=magenta
" misc
hi MoreMsg          ctermfg=darkgreen                       guifg=green
hi ModeMsg          ctermfg=darkred                         guifg=red
hi VertSplit        ctermfg=grey        ctermbg=black       guifg=black guibg=grey
hi Title            ctermfg=darkblue                        guifg=red guibg=grey
hi Visual           ctermfg=darkblue    ctermbg=darkyellow  guifg=darkblue guibg=yellow
hi WildMenu         ctermfg=black       ctermbg=darkcyan    guifg=black guibg=cyan
" link - diff/patch
hi def link diffAdded 		DiffAdd
hi def link diffRemoved 	DiffDelete
hi def link diffFile		DiffText
hi def link diffSubname 	String
hi def link diffLine 		String
" }}}

