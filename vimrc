" General {{{
set termencoding=&encoding
set fileencodings=UTF-8,GB2312,BIG5
set fileformats=unix,dos
set guifont=Envy\ Code\ R\ 11,
set guifontwide=WenQuanYi\ Zen\ Hei\ 11,
set mouse=a " 开启鼠标支持
set expandtab " TAB -> SPACE
set tabstop=4 " TAB 的宽度
set shiftwidth=4 " 缩进的宽度
set softtabstop=4
set clipboard=unnamed " 使用系统剪贴板
set backspace=indent,eol,start " 退格
set foldmethod=marker
set ignorecase " 搜索忽略大小写
set autoindent " 自动缩进
set number " 显示行数
set completeopt=longest,menu " 显示补全预览菜单
set smartcase
syn on " 语法高亮
filetype plugin indent on
let mapleader=","
set hidden " 用隐藏代替关闭从而保留 undo 列表等私有信息
set nocompatible
set nohls " 不高亮匹配关键字
set noincsearch " 非渐进搜索
set nowrap " 不自动折行
set updatetime=1000
set matchpairs=(:),{:} " 避免TabBar的方括号被高亮
set statusline=%<%f\ %h%m%r%=%P
set winaltkeys=no
set guioptions=ai
set cinoptions=":0,g0,t0"
set timeout
set timeoutlen=3000
set ttimeoutlen=300
set makeprg=make\ -j2
" }}}

" Function {{{
" 打开/关闭/切换 Quickfix 窗口
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

        copen 18
        let g:qfix_win = bufnr("$")
    endif

    exec "redraw!"
endfunction

" 空格键 下翻页
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

    " TODO 避免布局依赖
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

" P键 预览
function G_GoodP()
    if &buftype == "quickfix"
        exec "normal \<Return>"
        normal zz
        wincmd w
    elseif bufname('%') == "__MRU_Files__"
        exec "normal \<Return>"
        exec ":MRU"
    else
        unmap p
        normal p
        nnor <silent> <unique> p :call G_GoodP()<CR>
    endif
endfunction

" 跳转至文件编辑窗口
" 参照 tabbar.vim 插件的 <SID>Bf_CrSel() 函数
function G_GotoEditor()
    if bufname('%') == '__Tag_List__-' || getbufvar(bufnr('%'), '&modifiable') == 0
        wincmd w
    elseif bufname('%') == '-TabBar-' || getbufvar(bufnr('%'), '&modifiable') == 0
        wincmd w
    elseif getbufvar(bufnr('%'), '&modifiable') == 0 " QuickFix 或其他不可编辑的窗口
        wincmd w
    else " 已找到可编辑的窗口
        return
    endif

    call G_GotoEditor()
endfunction

" 关闭当前 Buffer
function G_CloseBuffer()
    call G_QFixToggle(0)
    call G_GotoEditor()

    if exists("g:bufexplorer_version")
        exec "BufExplorer"
        normal d
        exec "normal \<CR>"
    else
        exec "bd"
    endif
endfunction

" vim macro to jump to devhelp topics.
" ref: http://blog.csdn.net/ThinkHY/archive/2008/12/30/3655697.aspx
function! DevHelpCurrentWord()
    let word = expand("<cword>")
    exe "!devhelp -s " . word . " &"
endfunction

" 在当前文件中查找
function G_FindInFile(search)
    call G_QFixToggle(0)
    call G_GotoEditor()

    if a:search == 'exact'
        let str = "\\<".expand('<cword>')."\\>"
    elseif a:search == 'fuzzy'
        let str = input('Search Pattern(f): ')
        if str == ""
            echo ""
            return
        endif
    endif

    let @/ = str
    exec ":vimgrep /".str."/j %"
    call G_QFixToggle(1)
endfunction

" }}}

" Key bindings {{{
" Mouse Bindings {{{2
map <silent> <unique> <2-LeftMouse> <C-]>zz
map <silent> <unique> <RightMouse> :call G_GotoEditor()<CR><C-O>zz
map <silent> <unique> <MiddleMouse> :call G_GotoEditor()<CR><C-I>zz

" Function Key {{{2
nmap <silent> <unique> <F1> :set cursorline!<CR>:set nocursorline?<CR>
imap <silent> <unique> <F1> <ESC>:set cursorline!<CR><ESC>:set nocursorline?<CR>a
nmap <silent> <unique> <F2> :set nowrap!<CR>:set nowrap?<CR>
imap <silent> <unique> <F2> <ESC>:set nowrap!<CR>:set nowrap?<CR>a
nmap <silent> <unique> <F3> :set nohls!<CR>:set nohls?<CR>
imap <silent> <unique> <F3> <ESC>:set nohls!<CR>:set nohls?<CR>a
nmap <silent> <unique> <F4> :set nopaste!<CR>:set nopaste?<CR>
imap <silent> <unique> <F4> <ESC>:set nopaste!<CR>:set nopaste?<CR>a
nmap <silent> <unique> <F5> :!git di %<CR>
imap <silent> <unique> <F5> <ESC>:!git di %<CR>a
nmap <silent> <unique> <F7> :call <SID>G_Asciidoc2Html()<CR>
nmap <silent> <unique> <F8> :make!<CR>:call G_QFixToggle(1)<CR>
imap <silent> <unique> <F8> <ESC>:make!<CR>:call G_QFixToggle(1)<CR>
nmap <silent> <unique> <F9> :!!<CR>
imap <silent> <unique> <F9> <ESC>:!!<CR>
nmap <silent> <unique> <F10> :Mru<CR>
nmap <silent> <unique> <F11> g]
vmap <silent> <unique> <F11> g]
nmap <silent> <unique> <F12> <C-]>zz
vmap <silent> <unique> <F12> <C-]>zz

" Single Key {{{2
nmap <silent> <unique> <Backspace> :call G_GotoEditor()<CR><C-O>zz
nmap <silent> <unique> \ :call G_GotoEditor()<CR><C-I>zz
nmap <silent> <unique> <Space> :call G_GoodSpace(1)<CR>
nmap <silent> <unique> qq :call G_QFixToggle(-1)<CR>
nnor <silent> <unique> p :call G_GoodP()<CR>
nmap <silent> <unique> - <C-U>
nmap <silent> <unique> ; zz
nmap <silent> <unique> ' 10[{kz<CR>
vmap <silent> <unique> + :Align =<CR>

" Shift+ {{{2
nnor <silent> <unique> H :call DevHelpCurrentWord()<CR>
nmap <silent> <unique> W :exec "%s /\\s\\+$//ge"<CR>:w<CR>

" Ctrl+ {{{2
nmap <silent> <unique> <C-Q> :qa!<CR>
imap <silent> <unique> <C-Q> <ESC>;
nmap <silent> <unique> <C-H> <C-W>h
nmap <silent> <unique> <C-J> <C-W>j
nmap <silent> <unique> <C-K> <C-W>k
nmap <silent> <unique> <C-L> <C-W>l
imap <silent> <unique> <C-W> <SPACE><ESC>dbs
imap <silent> <unique> <C-F> <ESC>ea
imap <silent> <unique> <C-B> <C-O>b
imap <silent> <unique> <C-D> <C-O>de
imap <silent> <unique> <C-H> <Left>
imap <silent> <unique> <C-J> <Down>
imap <silent> <unique> <C-K> <Up>
imap <silent> <unique> <C-L> <Right>
imap <silent> <unique> <C-S> <Backspace>
imap <silent> <unique> <C-C> <Del>
imap <silent> <unique> <C-Z> <C-O>u
nmap <silent> <unique> <C-A> ^
nmap <silent> <unique> <C-N> :call G_QFixToggle(0)<CR>:call G_GotoEditor()<CR>:bn!<CR>
nmap <silent> <unique> <C-P> :call G_QFixToggle(0)<CR>:call G_GotoEditor()<CR>:bp!<CR>

" Alt+ {{{2
nmap <silent> <unique> <ESC><Backspace> :call G_GotoEditor()<CR>:pop<CR>zz
nmap <silent> <unique> <ESC><F8> :make! install<CR>
imap <silent> <unique> <ESC><F8> <ESC>:make! install<CR>
nmap <silent> <unique> <ESC>\ :call G_GotoEditor()<CR>:tag<CR>zz
nmap <silent> <unique> <ESC>` :call G_GotoEditor()<CR>:e #<CR>
imap <silent> <unique> <ESC>` <ESC>:call G_GotoEditor()<CR>:e #<CR>a

" Leader+ , Leader char is ',' {{{2
nmap <silent> <unique> <Leader>1 :.diffget BASE<CR>:diffupdate<CR>
nmap <silent> <unique> <Leader>2 :.diffget LOCAL<CR>:diffupdate<CR>
nmap <silent> <unique> <Leader>3 :.diffget REMOTE<CR>:diffupdate<CR>
nmap <silent> <unique> <Leader>/ :call G_FindInFile('exact')<CR>
nmap <silent> <unique> <Leader>? :call G_FindInFile('fuzzy')<CR>
nmap <silent> <unique> <Leader>d :call G_CloseBuffer()<CR>
nmap <silent> <unique> <leader>l :call <SID>ShowTaglist()<CR>
nmap <silent> <unique> <leader>, :BufExplorer<CR>
nmap <silent> <unique> <leader>s :call <SID>CscopeFind('s', 'y')<CR>
nmap <silent> <unique> <leader>c :call <SID>CscopeFind('c', 'y')<CR>
nmap <silent> <unique> <leader>e :call <SID>CscopeFind('e', 'y')<CR>
nmap <silent> <unique> <leader>S :call <SID>CscopeFind('s', 'n')<CR>
nmap <silent> <unique> <leader>C :call <SID>CscopeFind('c', 'n')<CR>
nmap <silent> <unique> <leader>E :call <SID>CscopeFind('e', 'n')<CR>
nmap <silent> <unique> <leader>. :call <SID>VimwikiGoProject()<CR>
" }}}1

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

  " 让 checkpath 找到相关文件，便于 [I 正常工作
  autocmd BufEnter,WinEnter *.c,*.cc,*.cpp,*.cxx,*.h,*.hh,*.hpp
    \ set path+=./

  " 设定 StatusLine
  augroup StatusLine
      au! StatusLine
      au BufLeave * setlocal statusline=""
      au BufEnter * setlocal statusline=%<%F%(\ %m%h%w%y%r%)\ %a%=\ %l,%c%V/%L\ (%P)
  augroup END
endif
" }}}

" 9# Plugins {{{
" mru.vim 3.3-p1 : Plugin to manage Most Recently Used (MRU) files {{{2
" http://www.vim.org/scripts/script.php?script_id=521
"
" p1: @@529@@
"             let split_window = 0
let MRU_Max_Entries=256
let MRU_Exclude_Files='^/tmp/.*\|^/var/tmp/.*'
let MRU_Window_Height=18
let MRU_Add_Menu=0

" taglist.vim 4.5-p1 : Source code browser (supports C/C++, java, perl, python, tcl, sql, php, etc) {{{2
" http://www.vim.org/scripts/script.php?script_id=273
"
" p1: let win_dir = 'aboveleft vertical'
let Tlist_Ctags_Cmd = "/usr/bin/ctags-exuberant"
let Tlist_WinWidth = 35
let Tlist_Show_One_File = 1
let Tlist_Compact_Format = 1 " 紧凑显示，无空行
let Tlist_Enable_Fold_Column = 0 " 不显示竖线
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_Process_File_Always = 1
let Tlist_Use_Horiz_Window = 0
let Tlist_Use_SingleClick = 1
let Tlist_Sort_Type = "name"
let tlist_c_settings = 'c;p:prototype;f:implementation'
let tlist_cpp_settings = 'c++;c:object;p:prototype;f:implementation'

function <SID>ShowTaglist()
    if exists("g:loaded_taglist")
        call G_GotoEditor()
        exec "TlistToggle"
    endif
endfunction

" TabBar 0.7-p1 : Plugin to add tab bar (derived from miniBufExplorer) {{{2
" http://www.vim.org/scripts/script.php?script_id=1338
"
" p1: Bf_SwitchTo
"     使用 <Esc>1..9 快捷键切换buffer时,跳转至编辑窗口
let Tb_UseSingleClick = 1 " 单击切换
let Tb_TabWrap = 1 " 禁止跨行显示
let Tb_MaxSize = 0 "
let Tb_ModSelTarget = 1 " 跳转至编辑窗口
let Tb_SplitToEdge = 1 " 顶端，超越TagList窗口
if has("autocmd")
  autocmd BufWritePost *.c,*.cc,*.cpp,*.cxx,*.h,*.hh,*.hpp
    \ exec ":TbAup"
endif

" SuperTab 0.41 : Do all your insert-mode completion with Tab {{{2
" http://www.vim.org/scripts/script.php?script_id=1643
let SuperTabRetainCompletionType=1
let SuperTabDefaultCompletionType="<C-X><C-N>"
let SuperTabMappingForward="<Tab>"
let SuperTabMappingBackward="<S-Tab>"

" Echofunc 1.19 : Echo the function declaration in the command line for C/C++ {{{2
" http://www.vim.org/scripts/script.php?script_id=1735
let g:EchoFuncLangsUsed = ["c", "cpp", "lua", "java"]

" Cscope : Interactively examine a C program source {{{2
" http://cscope.sourceforge.net/
set tag=.cscope/cscope.tags,~/.tags;
if has("cscope")
    set csto=1
    set nocsverb
    set cspc=3
    set cscopequickfix=s-,c-,d-,i-,t-,e-

    autocmd BufNewFile,BufReadPost,FileReadPost *
      \ let &path = getcwd()."/*"

    " add any database in current directory
    if glob('.cscope') != ""
        exec "cscope add .cscope/cscope.out"
        exec "cscope reset"
    " else add database pointed to by environment
    elseif $CSCOPE_DB != ""
        exec "cscope add $CSCOPE_DB"
        exec "cscope reset"
    endif

    function <SID>CscopeRefresh()
        " 如果当前目录存在 .cscope/ 的话
        if glob('.cscope') != ""
            call system("cscope -kbq -i.cscope/cscope.files -f.cscope/cscope.out &")
            " 由于频繁保存引发的多个 ctags 间的互斥，可能会导致以下错误:
            " ctags: ".cscope/cscope.tags" doesn't look like a tag file; I refuse to overwrite it.
            " http://www.lslnet.com/linux/dosc1/55/linux-369438.htm
            call system("ps -e | grep ctags || ctags --c++-kinds=+p --fields=-fst+aS --extra=+q --tag-relative -L.cscope/cscope.files -f.cscope/cscope.tags &")
            exec "cscope add .cscope/cscope.out"
            exec "cscope reset"
        endif
    endfunction

    " 在后台更新 tags | cscope*，便于在代码间正确的跳转
    autocmd BufWritePost,FileWritePost *.c,*.cc,*.cpp,*.cxx,*.h,*.hh,*.hpp
	  \ call <SID>CscopeRefresh()
endif

" cscope 似乎不支持正则表达式,无法实现精确匹配
" https://bugzilla.redhat.com/show_bug.cgi?id=163330
function <SID>CscopeFind(mask, quick)
    call G_QFixToggle(0)
    call G_GotoEditor()
    if a:quick == 'y'
        let str = expand('<cword>')
    elseif a:quick == 'n'
        let str = input('Search Pattern('.a:mask.'): ')
        if str == ""
            echo ""
            return
        endif
    endif
    let @/ = "\\<".str."\\>"
    exec ":cs find ".a:mask." ".str

    " 显示搜索结果窗口
    call G_QFixToggle(1)
endfunction

" vimwiki 0.9.7 : Personal Wiki for Vim {{{2
" http://www.vim.org/scripts/script.php?script_id=2226
let g:vimwiki_list = [
            \ { 'proj': 'beta',     'path': '~/beta/wiki/',     'path_html': '~/beta/html/',     'ext': '.wiki' },
            \ { 'proj': 'dtv-gui',  'path': '~/dtv-gui/wiki/',  'path_html': '~/dtv-gui/html/',  'ext': '.wiki' },
            \ { 'proj': 'gpicview', 'path': '~/gpicview/wiki/', 'path_html': '~/gpicview/html/', 'ext': '.wiki' },
            \ { 'proj': 'mouse-fm', 'path': '~/mouse-fm/wiki/', 'path_html': '~/mouse-fm/html/', 'ext': '.wiki' },
            \ { 'proj': 'pidgin',   'path': '~/pidgin/wiki/',   'path_html': '~/pidgin/html/',   'ext': '.wiki' },
            \ { 'proj': 'stardict', 'path': '~/stardict/wiki/', 'path_html': '~/stardict/html/', 'ext': '.wiki' },
            \ { 'proj': 'myqq',     'path': '~/myqq/wiki/',     'path_html': '~/myqq/html/',     'ext': '.wiki' },
            \ { 'proj': 'oxstroke', 'path': '~/oxstroke/wiki/', 'path_html': '~/oxstroke/html/', 'ext': '.wiki' },
            \ { 'proj': 'fbreader', 'path': '~/fbreader/wiki/', 'path_html': '~/fbreader/html/', 'ext': '.wiki' }]
function <SID>VimwikiGoProject()
    let proj_path = expand('~/')
    let idx = 1
    for wiki in g:vimwiki_list
        if stridx(getcwd(), wiki.proj, strlen(proj_path)) > 0
            call vimwiki#WikiGoHome(idx)
            call vimwiki_html#WikiAll2HTML(wiki.path_html)
            return
        endif
        let idx += 1
    endfor
endfunction

function <SID>G_Asciidoc2Html()
    let wiki = g:vimwiki_list[g:vimwiki_current_idx]['path']
    let html = g:vimwiki_list[g:vimwiki_current_idx]['path_html']
    let src  = expand('%:f')
    let dst  = expand('%:t:r').".html"
    exec ":! asciidoc -o ".html.dst." ".wiki.src
endfunction

" snipMate 0.83 : TextMate-style snippets for Vim {{{2
" http://www.vim.org/scripts/script.php?script_id=2540
" nothing

" quickfixsigns 0.5 : Mark quickfix & location list items with signs {{{2
" http://www.vim.org/scripts/script.php?script_id=2584
set lazyredraw

" }}}1

" Colour {{{
let g:colors_name="blue"

" First remove all existing highlighting.
hi clear
if exists("syntax_on")
  syntax reset
endif

set background=dark

hi Comment          ctermfg=darkgreen                       cterm=italic        guifg=darkgreen                         gui=italic
hi Constant         ctermfg=darkcyan                                            guifg=darkcyan
hi Special          ctermfg=darkred                                             guifg=darkred
hi PreProc          ctermfg=darkmagenta                                         guifg=darkmagenta
hi Statement        ctermfg=darkblue                                            guifg=lightblue
hi Type             ctermfg=darkblue                                            guifg=lightblue
hi Underlined       ctermfg=NONE        ctermbg=NONE        cterm=underline     guifg=NONE          guibg=NONE          gui=underline
hi Ignore           ctermfg=darkgrey    ctermbg=NONE                            guifg=darkgrey      guibg=NONE
hi Error            ctermfg=black       ctermbg=darkred     cterm=bold          guifg=white         guibg=darkred       gui=bold
hi Todo             ctermfg=white       ctermbg=darkgreen   cterm=bold          guifg=white         guibg=darkgreen     gui=bold
hi String           ctermfg=darkcyan                                            guifg=darkcyan
hi Identifier       ctermfg=grey        ctermbg=NONE                            guifg=lightgrey     guibg=NONE
hi Normal           ctermfg=NONE        ctermbg=NONE                            guifg=yellow        guibg=#222222
hi Pmenu            ctermfg=black       ctermbg=magenta                         guifg=black         guibg=magenta
hi PmenuSel         ctermfg=yellow      ctermbg=darkblue    cterm=bold          guifg=yellow        guibg=darkblue      gui=bold
hi SpecialKey       ctermfg=white       ctermbg=red         cterm=underline     guifg=white         guibg=red           gui=underline
hi NonText          ctermfg=magenta     ctermbg=NONE                            guifg=magenta       guibg=NONE
hi Directory        ctermfg=darkblue    ctermbg=NONE                            guifg=lightblue     guibg=NONE
hi ErrorMsg         ctermfg=darkred     ctermbg=NONE                            guifg=darkred       guibg=NONE
hi WarningMsg       ctermfg=white       ctermbg=NONE                            guifg=white         guibg=NONE
hi MatchParen       ctermfg=black       ctermbg=cyan        cterm=italic        guifg=black         guibg=cyan          gui=italic
hi VertSplit        ctermfg=white       ctermbg=NONE        cterm=bold          guifg=white         guibg=NONE          gui=bold
hi StatusLine       ctermfg=white       ctermbg=black                           guifg=white         guibg=black
hi StatusLineNC     ctermfg=white       ctermbg=black                           guifg=white         guibg=black
hi IncSearch        ctermfg=darkblue    ctermbg=white                           guifg=darkyellow    guibg=blue
hi Search           ctermfg=red         ctermbg=NONE        cterm=bold          guifg=darkyellow    guibg=blue
hi Question         ctermfg=magenta                                             guifg=magenta
hi LineNr           ctermfg=darkgreen                       cterm=italic        guifg=darkgreen     guibg=NONE          gui=italic
hi DiffAdd          ctermfg=darkgreen   ctermbg=NONE                            guifg=darkgreen     guibg=NONE
hi DiffChange       ctermfg=blue        ctermbg=black                           guifg=lightblue     guibg=black
hi DiffDelete       ctermfg=darkred     ctermbg=NONE                            guifg=darkred       guibg=NONE
hi DiffText         ctermfg=yellow      ctermbg=NONE                            guifg=yellow        guibg=NONE
hi Folded           ctermfg=green       ctermbg=NONE        cterm=italic        guifg=green         guibg=NONE          gui=italic
hi FoldColumn       ctermfg=darkgreen   ctermbg=NONE                            guifg=darkgreen     guibg=NONE
hi SignColumn       ctermfg=white       ctermbg=NONE                            guifg=white         guibg=NONE
hi MoreMsg          ctermfg=darkgreen                                           guifg=darkgreen
hi ModeMsg          ctermfg=darkred                                             guifg=darkred
hi Title            ctermfg=darkblue                                            guifg=lightblue
hi Visual           ctermfg=white       ctermbg=darkblue                        guifg=white         guibg=blue
hi WildMenu         ctermfg=white       ctermbg=yellow                          guifg=white         guibg=yellow
" link - diff/patch
hi def link diffAdded   DiffAdd
hi def link diffRemoved DiffDelete
hi def link diffFile    DiffText
hi def link diffSubname String
hi def link diffLine    String
" vimwiki
hi VimwikiItalic                                            cterm=italic
hi VimwikiDelText       ctermfg=black
hi VimwikiWord          ctermfg=darkblue
hi VimwikiNoExistsWord  ctermfg=cyan                        cterm=Underline
hi VimwikiList          ctermfg=green
" taglist
hi MyTagListTagName     ctermfg=white       ctermbg=NONE
hi MyTagListFileName    ctermfg=green       ctermbg=NONE
hi MyTagListTitle       ctermfg=grey        ctermbg=NONE
hi MyTagListTagScope    ctermfg=NONE        ctermbg=NONE
" tabbar
hi Tb_Normal            ctermfg=darkgreen   ctermbg=NONE
hi Tb_Changed           ctermfg=red         ctermbg=NONE
hi Tb_VisibleNormal     ctermfg=black       ctermbg=white
hi Tb_VisibleChanged    ctermfg=red         ctermbg=white
hi Tb_Readonly          ctermfg=green       ctermbg=NONE
hi Tb_VisibleReadonly   ctermfg=black       ctermbg=green
" }}}
