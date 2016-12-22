" General {{{1
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,sjis,euc-jp,cp932,euc-cn,cp936,euc-tw,big5
set termencoding=utf-8
set fileformats=unix,dos
set mouse=a " 开启鼠标支持
set expandtab " TAB is soft
set tabstop=4 " TAB 的宽度
set shiftwidth=4 " 缩进的宽度
set softtabstop=4
set clipboard=unnamed " 使用系统剪贴板
set backspace=indent,eol,start " 退格
set foldmethod=marker
set ignorecase " 搜索忽略大小写
set autoindent " 自动缩进
set cindent
set number " 显示行数
set completeopt=preview,menu " 显示补全预览菜单
set smartcase
set hidden " 用隐藏代替关闭从而保留 undo 列表等私有信息
set nocompatible
set nohls " 不高亮匹配关键字
set noincsearch " 非渐进搜索
set nowrap " 不自动折行
set updatetime=1000
set matchpairs=(:),{:} " 避免TabBar的方括号被高亮
set showcmd " 右下方显示按键序列
set winaltkeys=no
set cinoptions=:0
set timeoutlen=1000
set ttimeoutlen=100
set timeout
"set ttimeout
set autoread
set autowrite
set wildignore=*/*.o,*/*.so,*/*.obj,*/*.orig,*/.git/*,*/.hg/*,*/.svn/*
set wildmenu
set wildmode=list:longest,full
set viminfo+=! " 为了 mark 能保存高亮信息
set listchars=tab:.\ ,trail:\ ,
set noswapfile " 内存大、禁用swapfile
set history=200 " 命令行历史记录
set laststatus=2 " 始终显示状态栏
set noshowmode " 忽略内置的模式显示功能
set undolevels=500
set diffopt=filler,iwhite

if has("gui_running")
    set guioptions-=m
    set guioptions-=T
endif

if has("win32") || has("win64")
    au GUIEnter * simalt ~x
    language messages zh_CN.UTF-8
    set grepprg=findstr\ /n
    set guifont=Envy_Code_R_For_Powerline:h10
    set guifontwide=NSimsun:h10.5
    set shell=cmd.exe
    set directory=$TMP
else
    set guifont=Envy\ Code\ R\ For\ Powerline\ 10
    set guifontwide=WenQuanYi\ Micro\ Hei\ 10
    set makeprg=make\ -j2
    set grepprg=ack-grep\ -a
    set shell=bash\ -x\ -c
    set directory=/tmp
endif

if &term =~ "rxvt-unicode" || &term == "nvim"
    color light256
    " 区别普通/插入模式的光标颜色
    " # PowerLine 已实现
    " let &t_SI = "\033]12;black\007"
    " let &t_EI = "\033]12;red\007"
    " autocmd VimLeave * :!echo -ne "\033]12;black\007"
else
    color delek
endif

" 用全角显示『○』、『△』、『□』这样的特殊字符
" East Asian Ambiguous Width:
" http://www.unicode.org/reports/tr11/
" http://lists.debian.or.jp/debian-devel/200703/msg00038.html
" http://sakurapup.browserloadofcoolness.com/viewtopic.php?f=13&t=2027
" http://du1abadd.org/debian/UTF-8-EAW-FULLWIDTH.gz
set ambiwidth=double
" 不用设置为double也能全角显示，vim@rxvt-unicode

let mapleader=','
let maplocalleader='\'
let html_dynamic_folds=1
let c_space_errors=1
let sh_minlines = 100
syn enable " 语法高亮
filetype plugin indent on

if v:version >= 703
    set undodir=~/.vimundo/
    set undofile
endif
" }}}

" Function {{{1
" 打开/关闭/切换 Quickfix 窗口
" @forced:
"   1 always show qfix
"   0 always hide qfix
"  -1 switch show/hide
" function! G_QFixToggle(forced)
"     if bufname('%') == "[Command Line]"
"         " leave the command-line window: <C-\><C-N> is better then :quit
"         exec "normal \<C-\>\<C-N>"
"     elseif a:forced == 1
"         UniteResume
"     elseif a:forced == 0
"         UniteClose default
"     else
"         Unite -toggle quickfix
"     endif
" endfunction

" P键 预览
" function! G_GoodP()
"     if &buftype == "quickfix"
"         exec "normal \<Return>"
"         normal zz
"         wincmd w
"     else
"         unmap p
"         normal p
"         nnor <silent> <unique> p :call G_GoodP()<CR>
"     endif
" endfunction

" Space键 翻页/打开折叠
function! G_GoodSpace()
    if foldclosed('.') != -1
        normal zO
    else
        exec "normal \<C-D>"
    endif
endfunction

" 0键在行首与行顶间交替
function! G_Good0()
    if ! exists("b:is_pressed0")
        normal ^
        let b:is_pressed0 = 1
    else
        normal g0
        unlet b:is_pressed0
    endif
endfunction

" 跳转至文件编辑窗口
" 参照 tabbar.vim 插件的 <SID>Bf_CrSel() 函数
function! G_GotoEditor()
    if &buftype != ''
        wincmd w
        if &buftype != ''
            wincmd w
            if &buftype != ''
                wincmd w
                if &buftype != ''
                    wincmd W
                    wincmd W
                    wincmd W
                endif
            endif
        endif
    endif
endfunction

" 关闭当前 Buffer
function! G_CloseBuffer()
    call G_GotoEditor()
    let name = fnamemodify(expand('%'), ':t')

    "if bufname('%') != '-MiniBufExplorer-'
    "    wincmd k
    "    if bufname('%') != '-MiniBufExplorer-'
    "        wincmd k
    "        if bufname('%') != '-MiniBufExplorer-'
    "            wincmd k
    "            if bufname('%') != '-MiniBufExplorer-'
    "                return
    "            endif
    "        endif
    "    endif
    "endif

    exec "normal /" . name . "\<CR>"
    normal d
    call G_GotoEditor()
endfunction

" vim macro to jump to devhelp topics.
" ref: http://blog.csdn.net/ThinkHY/archive/2008/12/30/3655697.aspx
function! DevHelpCurrentWord()
    let word = expand("<cword>")
    exe "!devhelp -s " . word . " &"
endfunction

" jekyll blog
function! G_Jekyll()

endfunction

" Ranger file manager
" function Ranger()
"   silent !ranger --choosefile=/tmp/chosen
"   if filereadable('/tmp/chosen')
"     exec 'edit ' . system('cat /tmp/chosen')
"     call system('rm /tmp/chosen')
"   endif
"   redraw!
" endfunction
" }}}

" Key maps {{{1
" Mouse Bindings {{{2
"map <silent> <unique> <2-LeftMouse> :call G_GotoEditor()<CR><C-O>zz
"map <silent> <unique> <2-RightMouse> :call G_GotoEditor()<CR><C-I>g`"zz
map <silent> <unique> <MiddleMouse> <C-]>zz
map <silent> <unique> <LeftMouse><RightMouse> ZQ

" Function Key {{{2
nmap <silent> <unique> <F1> :let &colorcolumn=80-&colorcolumn<CR>:set list!<CR>
imap <silent> <unique> <F1> <ESC>:let &colorcolumn=80-&colorcolumn<CR>:set list!<CR>a
nmap <silent> <unique> <F2> :set nowrap!<CR>:set nowrap?<CR>
imap <silent> <unique> <F2> <ESC>:set nowrap!<CR>:set nowrap?<CR>a
nmap <silent> <unique> <F3> :set nohls!<CR>:set nohls?<CR>
imap <silent> <unique> <F3> <ESC>:set nohls!<CR>:set nohls?<CR>a
nmap <silent> <unique> <F4> :set nopaste!<CR>:set nopaste?<CR>
imap <silent> <unique> <F4> <ESC>:set nopaste!<CR>:set nopaste?<CR>a
set pastetoggle=<F4>
nmap          <unique> <F5> :!git difftool --tool=vimdiff -y HEAD -- %<LEFT><LEFT><LEFT><LEFT><LEFT>
nmap <silent> <unique> <F6> :<CR>
nmap          <unique> <F7> :set formatoptions+=12mnM<CR>
nmap <silent> <unique> <F8> :make!<CR>
nmap <silent> <unique> <F9> :Unite file_mru buffer bookmark directory_mru<CR>
nmap <silent> <unique> <F10> :<CR>
nmap <silent> <unique> <F11> <ESC>:tselect <C-R>=expand('<cword>')<CR><CR>
nmap <silent> <unique> <F12> <C-]>zz

" Single Key {{{2
nmap <silent> <unique> <Backspace> :call G_GotoEditor()<CR><C-O>zz
nmap <silent> <unique> \ :call G_GotoEditor()<CR><C-I>zz
nmap <silent> <unique> <Space> :call G_GoodSpace()<CR>
nmap <silent> <unique> qq :UniteResume<CR>
nmap <silent> <unique> - <C-U>
nmap <silent> <unique> ; zz
nmap <silent> <unique> ' 10[{kz<CR>
vmap <silent> <unique> + :Align =<CR>
nmap <silent> <unique> 0 :call G_Good0()<CR>

" Shift+ {{{2
nnor <silent> <unique> H :call DevHelpCurrentWord()<CR>
nmap <silent>          W :exec "%s /\\s\\+$//ge"<CR>:w<CR>
nmap <silent> <unique> Q :qa!<CR>
nmap          <unique> <S-F7> :set formatoptions-=2mn<CR>
nmap          <unique> <S-F8> :SyntasticCheck<CR>
nmap <silent> <unique> <S-F9> q:<UP>
nmap <silent> <unique> <S-F11> <ESC>:ptselect <C-R>=expand('<cword>')<CR><CR>
imap <silent> <unique> <S-Space> <C-V><Space>

" Ctrl+ {{{2
nmap <silent> <unique> <C-Q> :q!<CR>
nmap <silent> <unique> <C-J> :call EasyMotion#JK(0, 0)<CR>
nmap <silent> <unique> <C-K> :call EasyMotion#JK(0, 1)<CR>
nmap <silent> <unique> <C-N> :call G_GotoEditor()<CR>:bn!<CR>
nmap <silent> <unique> <C-P> :call G_GotoEditor()<CR>:bp!<CR>
imap <silent> <unique> <C-Q> <ESC><ESC>;
imap <silent> <unique> <C-E> <C-O>$
imap <silent> <unique> <C-A> <C-O>^
imap <silent> <unique> <C-F> <Right>
imap <silent> <unique> <C-B> <Left>
imap <silent> <unique> <C-J> <Down>
imap <silent> <unique> <C-D> <C-O>x
imap <silent> <unique> <C-K> <C-O>d$
imap <silent> <unique> <C-U> <C-O>v^x
imap <silent> <unique> <C-Y> <C-O>u<C-O>$
imap <silent> <unique> <C-H> <Backspace>
nmap <silent> <unique> <C-F8> :make! clean<CR>
nmap <silent> <unique> <C-F12> :!mkdir -p ~/__html__/%:h<CR>:TOhtml<CR>:w! ~/__html__/%<CR>:bw!<CR><C-L>

" Alt+ {{{2
if has("gui_running")
nmap <silent> <unique> <A-h> <C-W>h
nmap <silent> <unique> <A-j> <C-W>j
nmap <silent> <unique> <A-k> <C-W>k
nmap <silent> <unique> <A-l> <C-W>l
imap <silent> <unique> <A-b> <C-O>b
imap <silent> <unique> <A-f> <C-O>w
imap <silent> <unique> <A-d> <C-O>dw
elseif &term == "nvim"
nmap <silent> <unique> <M-Backspace> :call G_GotoEditor()<CR>:pop<CR>zz
nmap <silent> <unique> <M-\> :call G_GotoEditor()<CR>:tag<CR>zz
nmap <silent> <unique> <M-`> :call G_GotoEditor()<CR>:e #<CR>
imap <silent> <unique> <M-`> <ESC>:call G_GotoEditor()<CR>:e #<CR>a
nmap <silent> <unique> <M-h> <C-W>h
nmap <silent> <unique> <M-j> <C-W>j
nmap <silent> <unique> <M-k> <C-W>k
nmap <silent> <unique> <M-l> <C-W>l
imap <silent> <unique> <M-b> <C-O>b
imap <silent> <unique> <M-f> <C-O>w
imap <silent> <unique> <M-d> <C-O>dw
else
nmap <silent> <unique> <Esc><Backspace> :call G_GotoEditor()<CR>:pop<CR>zz
nmap <silent> <unique> <Esc>\ :call G_GotoEditor()<CR>:tag<CR>zz
nmap <silent> <unique> <Esc>` :call G_GotoEditor()<CR>:e #<CR>
imap <silent> <unique> <Esc>` <ESC>:call G_GotoEditor()<CR>:e #<CR>a
nmap <silent> <unique> <Esc>h <C-W>h
nmap <silent> <unique> <Esc>j <C-W>j
nmap <silent> <unique> <Esc>k <C-W>k
nmap <silent> <unique> <Esc>l <C-W>l
imap <silent> <unique> <Esc>b <C-O>b
imap <silent> <unique> <Esc>f <C-O>w
imap <silent> <unique> <Esc>d <C-O>dw
endif

" Leader+ , Leader char is ',' {{{2
nmap <silent> <unique> <Leader>1 :.diffget BASE<CR>:diffupdate<CR>
nmap <silent> <unique> <Leader>2 :.diffget LOCAL<CR>:diffupdate<CR>
nmap <silent> <unique> <Leader>3 :.diffget REMOTE<CR>:diffupdate<CR>
nmap <silent> <unique> <Leader>/ :Unite grep:%::<C-R>=expand("<cword>")<CR><CR>
nmap <silent> <unique> <Leader>? :Unite grep:%::<CR>
nmap <silent> <unique> <Leader>g :Unite grep:.::<C-R>=expand("<cword>")<CR><CR>
nmap <silent> <unique> <Leader>G :Unite grep:.::<CR>
vmap <silent> <unique> <Leader>/ y:Unite grep:%::<C-R>=@"<CR><CR>
vmap <silent> <unique> <Leader>g y:Unite grep:.::<C-R>=@"<CR><CR>
nmap <silent> <unique> <Leader>d :call G_CloseBuffer()<CR>
nmap <silent> <unique> <Leader>l :call <SID>ShowTagbar()<CR>
nmap <silent> <unique> <Leader>s :call <SID>CscopeFind('s', 'y')<CR>
nmap <silent> <unique> <Leader>c :call <SID>CscopeFind('c', 'y')<CR>
nmap <silent> <unique> <Leader>S :call <SID>CscopeFind('s', 'n')<CR>
nmap <silent> <unique> <Leader>C :call <SID>CscopeFind('c', 'n')<CR>
nmap <silent> <unique> <Leader>a :GundoToggle<CR>

" Colon+, Colon char is ':' {{{2
command W :w !sudo tee %
command E :call Ranger()<CR>

command PP :!paps --landscape --font='monospace 8' --header --columns=2 % | ps2pdf - - | zathura -
command PPP :!paps --landscape --font='monospace 8' --header --columns=2 % | lp -o landscape -o sites=two-sided-long-edge -

command S :UniteSessionSave
command L :UniteSessionLoad
" }}}1

" Autocmd {{{1
if has("autocmd")
    function! <SID>AC_ResetCursorPosition()
        if line("'\"") > 1 && line("'\"") <= line("$")
            exec "normal g`\"zz"
        endif
    endfunction

    function! <SID>AC_HighlightDirtySpace()
        highlight link wtfSpace SpecialKey
        match wtfSpace '　'
    endfunction

    function! <SID>AC_ChmodExecutable()
        if getline(1) =~ "^#!" && getline(1) =~ "/bin/"
            silent !chmod u+x %
            redraw!
        endif
    endfunction

    autocmd VimResized *
                \ redrawstatus!

    " 这样加快输入法自动切换时的体感速度
    autocmd InsertEnter * set timeoutlen=100
    autocmd InsertLeave * set timeoutlen=1000

    " 每次访问文件时都把光标放置在上次离开的位置
    autocmd BufReadPost *
                \ call <SID>AC_ResetCursorPosition()

    " 每次加载文件时都把全角空格'　'高亮显示出来
    autocmd BufReadPost *
                \ call <SID>AC_HighlightDirtySpace()

    " 写测试脚本的时候自动更新为可执行格式
    autocmd BufWritePost *
                \ call <SID>AC_ChmodExecutable()

    " 让 checkpath 找到相关文件，便于 [I 正常工作
    autocmd BufEnter,WinEnter *.c,*.cc,*.cpp,*.cxx,*.h,*.hh,*.hpp
                \ set path+=./,/usr/include/

    autocmd BufRead *.tjp
                \ set filetype=tjp

    autocmd Filetype java
                \ setlocal omnifunc=javacomplete#Complete
endif
" }}}

" Plugins {{{1
" Cscope : Interactively examine a C program source {{{2
" http://cscope.sourceforge.net/
autocmd Filetype java
    \ set tag=.cscope/cscope_java.tags,~/.tags_android,~/.tags_java6;
autocmd Filetype c,cpp
    \ set tag=.cscope/cscope_c.tags,.cscope/cscope_h.tags,~/.tags.c,~/.gtk-tags.c;
autocmd Filetype python
    \ set tag=.cscope/cscope.tags,/tmp/.tags_python;
if has("cscope")
    set csto=1
    set nocsverb
    set cspc=3
    set cscopequickfix=s-,c-,d-,i-,t-,e-

    autocmd BufNewFile,BufReadPost,FileReadPost *
      \ let &path = getcwd()

    " add any database in current working directory
    if glob(getcwd() . '/.cscope') != ""
        exec "cscope add ".getcwd()."/.cscope/cscope.out"
        exec "cscope reset"
    " else add database pointed to by environment
    elseif $CSCOPE_DB != ""
        exec "cscope add $CSCOPE_DB"
        exec "cscope reset"
    endif

    function! <SID>CscopeRefresh()
        " 如果当前目录存在 .cscope/ 的话
        if glob(getcwd() . '/.cscope') != ""
            call system("cscope -kbq -i.cscope/cscope.files -f.cscope/cscope.out &")
            " 由于频繁保存引发的多个 ctags 间的互斥，可能会导致以下错误:
            " ctags: ".cscope/cscope.tags" doesn't look like a tag file; I refuse to overwrite it.
            " http://www.lslnet.com/linux/dosc1/55/linux-369438.htm
            call system("ps -e | grep ctags || ctags --c++-kinds=+p --fields=+iaS --extra=+q --tag-relative -L.cscope/cscope.files -f.cscope/cscope.tags &")
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
function! <SID>CscopeFind(mask, quick)
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
    Unite quickfix
endfunction


" OmniCppComplete 0.41 : C/C++ omni-completion with ctags database {{{2
" http://www.vim.org/scripts/script.php?script_id=1520
let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
let OmniCpp_ShowAccess = 1 " show member access information
let OmniCpp_MayCompleteDot = 1 " autocomplete after .
let OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
let OmniCpp_MayCompleteScope = 1 " autocomplete after ::
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]
let OmniCpp_GlobalScopeSearch = 0 " 0 or 1


" pythoncomplete 0.9 : Python Omni Completion {{{2
" http://www.vim.org/scripts/script.php?script_id=1542
" nothing


" Mark 2.6.2 : Highlight several words in different colors simultaneously. {{{2
" http://www.vim.org/scripts/script.php?script_id=2666
let g:mwAutoLoadMarks = 1 " 自动加载高亮的 Mark
nmap <Plug>IgnoreMarkSearchAnyNext <Plug>MarkSearchAnyNext
nmap <Plug>IgnoreMarkSearchAnyPrev <Plug>MarkSearchAnyPrev


" autofmt 1.6 (2011-11-03): text formatting plugin {{{2
" http://www.vim.org/scripts/script.php?script_id=1939
" Use uax14
set formatexpr=autofmt#uax14#formatexpr()


"}}}1

" bundle {{{1
" call pathogen#infect('bundle')
" call pathogen#helptags()

call plug#begin('~/.config/nvim/bundle')
    Plug 'majutsushi/tagbar'
    Plug 'ervandew/supertab'
    Plug 'tomtom/quickfixsigns_vim'
    Plug 'Raimondi/delimitMate'
    Plug 'sjl/gundo.vim'
    Plug 'chrisbra/NrrwRgn'
    Plug 'scrooloose/syntastic'
    Plug 'easymotion/vim-easymotion'
    Plug 'vim-pandoc/vim-pandoc'
    Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'
    Plug 'Shougo/neosnippet-snippets' | Plug 'Shougo/neosnippet.vim'
    Plug 'Shougo/unite.vim' | Plug 'Shougo/neomru.vim'
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    Plug 'Shougo/neocomplete.vim'
    Plug 'vim-scripts/fcitx.vim'
    Plug 'vim-scripts/VisIncr'
    Plug 'wgurecky/vimSum'
    Plug 'itchyny/calendar.vim'
    Plug 'mmai/wikilink'
    Plug 'MicahElliott/Rocannon'
call plug#end()

" MiniBufExplorer 6.4.4: Elegant buffer explorer - takes very little screen space {{{2
" http://www.vim.org/scripts/script.php?script_id=159 (origin)
" https://github.com/fholgado/minibufexpl.vim (improved)
"
" ppa1: (过时的)
"     为了配合 Powerline 显示，修改了源文件
"
" 被 airline 的 extensions#tabline 替代
" --
"let g:miniBufExplShowBufNumbers = 1
"let g:miniBufExplModSelTarget = 1
"let g:miniBufExplCheckDupeBufs = 0
"let g:miniBufExplMapWindowNavVim = 0
" -- 2015/04/16


" Tagbar v2.4.1: Display tags of the current file ordered by scope {{{2
" http://www.vim.org/scripts/script.php?script_id=3465
" https://github.com/majutsushi/tagbar
let g:tagbar_width = 35
let g:tagbar_autofocus = 1
function! <SID>ShowTagbar()
    call G_GotoEditor()
    exec ":TagbarToggle"
endfunction


" SuperTab 1.6 : Do all your insert-mode completion with Tab {{{2
" http://www.vim.org/scripts/script.php?script_id=1643
" https://github.com/ervandew/supertab
let SuperTabCrMapping=0 " 该项和delimitMate的expand_cr选项冲突
let SuperTabRetainCompletionType=1
let SuperTabDefaultCompletionType="<C-X><C-U>" "配合neocomplcache使用时，单独使用时<C-X><C-N>局部补全
let SuperTabMappingForward="<Tab>"
let SuperTabMappingBackward="<S-Tab>"


" quickfixsigns 1.00 : Mark quickfix & location list items with signs {{{2
" http://www.vim.org/scripts/script.php?script_id=2584
" https://github.com/tomtom/quickfixsigns_vim
let quickfixsigns_blacklist_buffer = '^[_-].*[_-]$' "忽略 TabBar 和 -TabBar- 这两个 Buffer


" delimitMate.vim 2.6 : Provides auto-balancing and some expansions for parens, quotes, etc. {{{2
" http://www.vim.org/scripts/script.php?script_id=2754
" https://github.com/Raimondi/delimitMate
let delimitMate_autoclose = 1
"let delimitMate_quotes = "\" ' `"
"let delimitMate_nesting_quotes = []
"let delimitMate_matchpairs = "(:),[:],{:},<:>"
let delimitMate_expand_cr = 1 " 该项和SuperTab的CrMapping选项冲突
"let delimitMate_smart_quotes = 1
"let delimitMate_balance_matchpairs = 1


" Gundo 2.4.0 : Visualize your undo tree {{{2
" http://www.vim.org/scripts/script.php?script_id=3304
" https://github.com/sjl/gundo.vim
let g:gundo_preview_height = 50
let g:gundo_preview_bottom = 0
let g:gundo_right = 0


" NrrwRgn 26 : A Narrow Region Plugin similar to Emacs {{{2
" http://www.vim.org/scripts/script.php?script_id=3075
" https://github.com/chrisbra/NrrwRgn
let g:nrrw_topbot_leftright = 'aboveleft'
let g:nrrw_rgn_wdth = 50


" Syntastic 2.3.0 : Automatic syntax checking {{{2
" http://www.vim.org/scripts/script.php?script_id=2736
let g:syntastic_check_on_open=1
let g:syntastic_auto_loc_list=2
let g:syntastic_quiet_messages = {'level': 'warnings'}
let g:syntastic_mode_map = { 'mode': 'passive',
                           \ 'active_filetypes': ['c', 'cpp'] }
let g:syntastic_c_remove_include_errors=1
let g:syntastic_cpp_remove_include_errors=1


" EasyMotion 1.3 : Vim motions on speed! {{{2
" www.vim.org/scripts/script.php?script_id=3526
" https://github.com/Lokaltog/vim-easymotion.git
let g:EasyMotion_leader_key = 'f'
let g:EasyMotion_grouping = 1
let g:EasyMotion_keys = "asdfghjklweruiomnFGHJKLUIOYPMN"


" vim-pandoc: vim bundle for pandoc users {{{2
" https://github.com/vim-pandoc/vim-pandoc
let g:pandoc_use_hard_wraps=1


" deoplete : Deoplete is the abbreviation of "dark powered neo-completion {{{2
" https://github.com/Shougo/deoplete.nvim
let g:deoplete#enable_at_startup = 0


" Rocannon : Vim for Ansible playbooks: omni-completion, abbreviations, syntax, folding, K-docs, and colorscheme {{{2
let g:rocannon_bypass_colorscheme = 1
autocmd FileType ansible setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType ansible setlocal foldmethod=marker


" 3# about statusline: vim-powerline、powerline、vim-airline {{{2
" 1. vim-powerline: The ultimate vim statusline utility. XXX has been deprecated {{{3
" 旧版的 powerline 专为 vim 设计
"   http://www.vim.org/scripts/script.php?script_id=3881
"   https://github.com/Lokaltog/vim-powerline
"
"   - 'fancy'符号依赖定制字体，详情参考
"       let g:Powerline_symbols = 'fancy'
"       https://github.com/Lokaltog/vim-powerline/wiki/Patched-fonts
"
" 2. powerline: The ultimate statusline/prompt utility. {{{3
" 新版的 powerline 完全使用 python 扩展了原有的设计
" 不仅支持 vim，还支持 bash/zsh、tmux、awesome
"   https://github.com/Lokaltog/powerline
"   https://powerline.readthedocs.org/en/latest/index.html
"
" # 在使用宽字符的情况下，状态栏右侧内容右对齐(冗余空格)的问题 @db80fc95ed
"   https://powerline.readthedocs.org/en/latest/fontpatching.html
"       - <UE0A0>...<UE0A2>
"       - <UE0B0>...<UE0b3>
" # 在使用单字符的情况下，状态栏左侧编辑模式显示不完全的问题 @db80fc95ed
"
" 3. vim-airline @e31d5f3: lean & mean status/tabline for vim that's light as air {{{3
" 完全使用 vim-scripts 实现的旧版的 vim-powerline，易于跨平台
"   https://github.com/bling/vim-airline
"
let g:airline_theme="powerlineish"
" 因为新版存在的宽字符问题，所以这里使用的是旧版的 vim-powerline 制作的字符
"   旧版的 vim-powerline symbols 使用以下编码
"       - <U2B60>
"       - <U2B61>
"       - <U2B64>
"       - <U2B80>...<U2B83>
let g:airline_left_sep = '⮀'
let g:airline_left_alt_sep = '⮁'
let g:airline_right_sep = '⮂'
let g:airline_right_alt_sep = '⮃'
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
    let g:airline_symbols.branch = '⭠'
    let g:airline_symbols.readonly = '⭤'
    let g:airline_symbols.linenr = '⭡'
endif
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#tab_nr_type = 0
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#left_sep = '⮀'
let g:airline#extensions#tabline#left_alt_sep = '⮁'
let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap <M-1> <Plug>AirlineSelectTab1
nmap <M-2> <Plug>AirlineSelectTab2
nmap <M-3> <Plug>AirlineSelectTab3
nmap <M-4> <Plug>AirlineSelectTab4
nmap <M-5> <Plug>AirlineSelectTab5
nmap <M-6> <Plug>AirlineSelectTab6
nmap <M-7> <Plug>AirlineSelectTab7
nmap <M-8> <Plug>AirlineSelectTab8
nmap <M-9> <Plug>AirlineSelectTab9
nmap <M-,> <Plug>AirlineSelectPrevTab
nmap <M-.> <Plug>AirlineSelectNextTab

"if !exists('g:airline_symbols')
"  let g:airline_symbols = {}
"endif
let g:airline#extensions#whitespace#symbol = ''
let g:airline#extensions#whitespace#trailing_format = '[T:%s]'
let g:airline#extensions#whitespace#mixed_indent_format = '[M:%s]'


" 4# Shougo's pack: https://github.com/Shougo/ {{{2 vimproc 7.0 : Asynchronous execution plugin for Vim {{{2
" nothing

" -nvim
"" neocomplcache 8.0: Ultimate auto-completion system for Vim. {{{3
"let g:neocomplcache_enable_at_startup = 1
"let g:neocomplcache_max_list = 20
"let g:neocomplcache_disable_auto_complete = 0
"let g:neocomplcache_enable_auto_select = 0
"let g:neocomplcache_enable_ignore_case = 0
"let g:neocomplCache_SmartCase = 1
"let g:neocomplcache_enable_underbar_completion = 1
"autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
"autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
"autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
"autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
"autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
"if !exists('g:neocomplcache_omni_patterns')
"    let g:neocomplcache_omni_patterns = {}
"endif
"let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
"let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplcache_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplcache_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'


" neosnippet {{{3
let g:neosnippet#snippets_directory = "$HOME/.vim/snippets/"
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)
" Plugin key-mappings.
imap <expr><Space> neosnippet#expandable() == 1 ? "\<Plug>(neosnippet_expand)" : "\<Space>"
" SuperTab like snippets behavior.
imap <expr><TAB> neosnippet#expandable_or_jumpable() ?  "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?  "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
" g:neosnippet#scope_aliases is a dictionary, initialize it if you haven't done it
let g:neosnippet#scope_aliases = {}
let g:neosnippet#scope_aliases['sls'] = 'sls-2014.1.13'

" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif


" unite.vim 5.0 : Unite all sources {{{3
"   | unite-outline
"   | unite-session
"   | unite-quickfix
"
let g:unite_source_file_mru_limit = 100
let g:unite_source_history_yank_enable = 0
let g:unite_cursor_line_highlight = 'TabLineSel'
let g:unite_split_rule = 'botright'
if executable('ack-grep')
    let g:unite_source_grep_command = 'ack-grep'
    let g:unite_source_grep_default_opts = '-iH --no-heading --no-color --all'
    let g:unite_source_grep_recursive_opt = '-R'
endif
autocmd FileType unite call s:unite_my_settings()
function! s:unite_my_settings()
    nmap <silent><buffer> <Space> <C-D>
    nmap <silent><buffer> t <Plug>(unite_toggle_mark_current_candidate)
    nmap <silent><buffer> a <Plug>(unite_append_enter)
    nmap <silent><buffer> x <Plug>(unite_choose_action)
    nmap <silent><buffer> . <Plug>(unite_rotate_next_source)
    nmap <silent><buffer> , <Plug>(unite_rotate_previous_source)
    nmap <silent><buffer> <Tab> <Plug>(unite_quick_match_default_action)
    imap <silent><buffer> <Tab> <Plug>(unite_select_next_line)
    imap <silent><buffer> <S-Tab> <Plug>(unite_select_previous_line)
    vmap <silent><buffer> t <Plug>(unite_toggle_mark_current_candidate)
endfunction


" neocomplete : Next generation completion framework after neocomplcache {{{3
" https://github.com/Shougo/neocomplete.vim
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'


" }}}2


" }}}1

" 3# keys ref: http://tinyurl.com/2cae5vw {{{1
" xterm keys {{{2
map  <Esc>[1;2P <S-F1>
map  <Esc>[1;2Q <S-F2>
map  <Esc>[1;2R <S-F3>
map  <Esc>[1;2S <S-F4>
map  <Esc>[15;2~ <S-F5>
map  <Esc>[17;2~ <S-F6>
map  <Esc>[18;2~ <S-F7>
map  <Esc>[19;2~ <S-F8>
map  <Esc>[20;2~ <S-F9>
map  <Esc>[21;2~ <S-F10>
map  <Esc>[23;2~ <S-F11>
map  <Esc>[24;2~ <S-F12>
map  <Esc>[1;5P <C-F1>
map  <Esc>[1;5Q <C-F2>
map  <Esc>[1;5R <C-F3>
map  <Esc>[1;5S <C-F4>
map  <Esc>[15;5~ <C-F5>
map  <Esc>[17;5~ <C-F6>
map  <Esc>[18;5~ <C-F7>
map  <Esc>[19;5~ <C-F8>
map  <Esc>[20;5~ <C-F9>
map  <Esc>[21;5~ <C-F10>
map  <Esc>[23;5~ <C-F11>
map  <Esc>[24;5~ <C-F12>
map! <Esc>[1;2P <S-F1>
map! <Esc>[1;2Q <S-F2>
map! <Esc>[1;2R <S-F3>
map! <Esc>[1;2S <S-F4>
map! <Esc>[15;2~ <S-F5>
map! <Esc>[17;2~ <S-F6>
map! <Esc>[18;2~ <S-F7>
map! <Esc>[19;2~ <S-F8>
map! <Esc>[20;2~ <S-F9>
map! <Esc>[21;2~ <S-F10>
map! <Esc>[23;2~ <S-F11>
map! <Esc>[24;2~ <S-F12>
map! <Esc>[1;5P <C-F1>
map! <Esc>[1;5Q <C-F2>
map! <Esc>[1;5R <C-F3>
map! <Esc>[1;5S <C-F4>
map! <Esc>[15;5~ <C-F5>
map! <Esc>[17;5~ <C-F6>
map! <Esc>[18;5~ <C-F7>
map! <Esc>[19;5~ <C-F8>
map! <Esc>[20;5~ <C-F9>
map! <Esc>[21;5~ <C-F10>
map! <Esc>[23;5~ <C-F11>
map! <Esc>[24;5~ <C-F12>

" gnome-terminal keys   {{{2
map  <Esc>O1;2P <S-F1>
map  <Esc>O1;2Q <S-F2>
map  <Esc>O1;2R <S-F3>
map  <Esc>O1;2S <S-F4>
map  <Esc>[15;2~ <S-F5>
map  <Esc>[17;2~ <S-F6>
map  <Esc>[18;2~ <S-F7>
map  <Esc>[19;2~ <S-F8>
map  <Esc>[20;2~ <S-F9>
" not available  <S-F10>
map  <Esc>[23;2~ <S-F11>
map  <Esc>[24;2~ <S-F12>
" not available <C-F1>
map  <Esc>O1;5Q <C-F2>
map  <Esc>O1;5R <C-F3>
map  <Esc>O1;5S <C-F4>
map  <Esc>[15;5~ <C-F5>
map  <Esc>[17;5~ <C-F6>
map  <Esc>[18;5~ <C-F7>
map  <Esc>[19;5~ <C-F8>
map  <Esc>[20;5~ <C-F9>
map  <Esc>[21;5~ <C-F10>
map  <Esc>[23;5~ <C-F11>
map  <Esc>[24;5~ <C-F12>

map! <Esc>O1;2P <S-F1>
map! <Esc>O1;2Q <S-F2>
map! <Esc>O1;2R <S-F3>
map! <Esc>O1;2S <S-F4>
map! <Esc>[15;2~ <S-F5>
map! <Esc>[17;2~ <S-F6>
map! <Esc>[18;2~ <S-F7>
map! <Esc>[19;2~ <S-F8>
map! <Esc>[20;2~ <S-F9>
" not available  <S-F10>
map! <Esc>[23;2~ <S-F11>
map! <Esc>[24;2~ <S-F12>
" not available <C-F1>
map! <Esc>O1;5Q <C-F2>
map! <Esc>O1;5R <C-F3>
map! <Esc>O1;5S <C-F4>
map! <Esc>[15;5~ <C-F5>
map! <Esc>[17;5~ <C-F6>
map! <Esc>[18;5~ <C-F7>
map! <Esc>[19;5~ <C-F8>
map! <Esc>[20;5~ <C-F9>
map! <Esc>[21;5~ <C-F10>
map! <Esc>[23;5~ <C-F11>
map! <Esc>[24;5~ <C-F12>

" rxvt keys {{{2
" <Esc>[23~ confilict between <S-F1> and <F11>
" <Esc>[24~ confilict between <S-F2> and <F12>
map  <Esc>[a   <S-Up>
map  <Esc>[b   <S-Down>
map  <Esc>[25~ <S-CR>
"    <Esc>[25~ <S-F3> " hack ~/.Xresources for vimwiki <S-CR> mapping
map  <Esc>[26~ <S-F4>
map  <Esc>[28~ <S-F5>
map  <Esc>[29~ <S-F6>
map  <Esc>[31~ <S-F7>
map  <Esc>[32~ <S-F8>
map  <Esc>[33~ <S-F9>
map  <Esc>[34~ <S-F10>
map  <Esc>[23$ <S-F11>
map  <Esc>[24$ <S-F12>
map  <Esc>[11^ <C-F1>
map  <Esc>[12^ <C-F2>
map  <Esc>[13^ <C-CR>
"    <Esc>[13^ <C-F3> " hack ~/.Xresources for vimwiki <C-CR> mapping
map  <Esc>[14^ <C-F4>
map  <Esc>[15^ <C-F5>
map  <Esc>[17^ <C-F6>
map  <Esc>[18^ <C-F7>
map  <Esc>[19^ <C-F8>
map  <Esc>[20^ <C-F9>
map  <Esc>[21^ <C-F10>
map  <Esc>[23^ <C-F11>
map  <Esc>[24^ <C-F12>
map! <Esc>[23~ <S-F1>
map! <Esc>[24~ <S-F2>
map! <Esc>[25~ <S-F3>
map! <Esc>[26~ <S-F4>
map! <Esc>[28~ <S-F5>
map! <Esc>[29~ <S-F6>
map! <Esc>[31~ <S-F7>
map! <Esc>[32~ <S-F8>
map! <Esc>[33~ <S-F9>
map! <Esc>[34~ <S-F10>
map! <Esc>[23$ <S-F11>
map! <Esc>[24$ <S-Space>
" URxvt.keysym.S-space: \033[24$
" map! <Esc>[24$ <S-F12>
map! <Esc>[11^ <C-F1>
map! <Esc>[12^ <C-F2>
map! <Esc>[13^ <C-F3>
map! <Esc>[14^ <C-F4>
map! <Esc>[15^ <C-F5>
map! <Esc>[17^ <C-F6>
map! <Esc>[18^ <C-F7>
map! <Esc>[19^ <C-F8>
map! <Esc>[20^ <C-F9>
map! <Esc>[21^ <C-F10>
map! <Esc>[23^ <C-F11>
map! <Esc>[24^ <C-F12>

" }}}1

