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
set completeopt=longest,menu " 显示补全预览菜单
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
set timeoutlen=500
set autoread
set autowrite
set wildignore=*/*.o,*/*.so,*/*.obj,*/*.orig,*/.git/*,*/.hg/*,*/.svn/*
set wildmenu
set wildmode=list:longest,full
set viminfo+=! " 为了 mark 能保存高亮信息
set listchars=tab:\ \ ,trail:\

if has("gui_running")
    set guioptions-=m
    set guioptions-=T
endif

if has("win32") || has("win64")
    au GUIEnter * simalt ~x
    language messages zh_CN.UTF-8
    set grepprg=findstr\ /n
    set guifont=Envy_Code_R:h10
    set guifontwide=NSimsun:h10.5
    set shell=cmd.exe
    set directory=$TMP
else
    set guifont=Envy\ Code\ R\ 10
    set guifontwide=WenQuanYi\ Micro\ Hei\ 10
    set makeprg=make\ -j2
    set grepprg=ack-grep\ -a
    set shell=bash\ -x\ -c
    set directory=/tmp
endif

if &term =~ "rxvt-unicode-256color"
    color light256
    " 区别普通/插入模式的光标颜色
    " C: 改由PowerLine实现
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

let mapleader=","
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
function! G_QFixToggle(forced)
    if bufname('%') == "[Command Line]"
        " leave the command-line window: <C-\><C-N> is better then :quit
        exec "normal \<C-\>\<C-N>"
    elseif exists("g:qfix_win")
        if a:forced == 1
            return
        endif

        cclose
        unlet g:qfix_win
    else
        if a:forced == 0
            return
        endif

        copen
        let g:qfix_win = bufnr("$")
    endif

    exec "redraw!"
endfunction

" P键 预览
function! G_GoodP()
    if &buftype == "quickfix"
        exec "normal \<Return>"
        normal zz
        wincmd w
    else
        unmap p
        normal p
        nnor <silent> <unique> p :call G_GoodP()<CR>
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

	if bufname('%') != '-TabBar-'
		wincmd k
		if bufname('%') != '-TabBar-'
			wincmd k
			if bufname('%') != '-TabBar-'
				wincmd k
				if bufname('%') != '-TabBar-'
					return
				endif
			endif
		endif
	endif

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

" 在文件中查找
function! G_FindInFiles(range, quick)
    call G_QFixToggle(0)
    call G_GotoEditor()

    if a:quick == 'y'
        let line = "-w ".expand('<cword>')
	elseif a:quick == 'v'
        let line = "-w ".@"
		let @/ = line
    elseif a:quick == 'n'
        let line  = input('Search Pattern(g): ')
        if line == ""
            echo ""
            return
        endif
    endif

    let words = split(line)
    for str in reverse(words)
        let @/ = str
        break
    endfor

    if a:range == 'single'
        exec ":grep! -H ".line." %"
    elseif a:range == 'golbal'
        exec ":grep! ".line
    endif

    call G_QFixToggle(1)
endfunction

" jekyll blog
function! G_Jekyll()

endfunction

" Ranger file manager
function Ranger()
  silent !ranger --choosefile=/tmp/chosen
  if filereadable('/tmp/chosen')
    exec 'edit ' . system('cat /tmp/chosen')
    call system('rm /tmp/chosen')
  endif
  redraw!
endfunction
" }}}

" Key bindings {{{1
" Mouse Bindings {{{2
map <silent> <unique> <2-LeftMouse> :call G_GotoEditor()<CR><C-O>zz
map <silent> <unique> <2-RightMouse> :call G_GotoEditor()<CR><C-I>g`"zz
map <silent> <unique> <MiddleMouse> <C-]>zz
map <silent> <unique> <LeftMouse><RightMouse> ZQ

" Function Key {{{2
nmap <silent> <unique> <F1> :let &colorcolumn=80-&colorcolumn<CR>
imap <silent> <unique> <F1> <ESC>:let &colorcolumn=80-&colorcolumn<CR>a
nmap <silent> <unique> <F2> :set nowrap!<CR>:set nowrap?<CR>
imap <silent> <unique> <F2> <ESC>:set nowrap!<CR>:set nowrap?<CR>a
nmap <silent> <unique> <F3> :set list!<CR>:set nohls!<CR>:set nohls?<CR>
imap <silent> <unique> <F3> <ESC>:set nohls!<CR>:set nohls?<CR>a
nmap <silent> <unique> <F4> :set nopaste!<CR>:set nopaste?<CR>
imap <silent> <unique> <F4> <ESC>:set nopaste!<CR>:set nopaste?<CR>a
set pastetoggle=<F4>
nmap          <unique> <F5> :!git difftool --tool=vimdiff -y HEAD -- %<LEFT><LEFT><LEFT><LEFT><LEFT>
nmap <silent> <unique> <F6> :ConqueTermSplit zsh<CR>
nmap          <unique> <F7> :set formatoptions+=12mnM<CR>
nmap <silent>          <F8> :make!<CR>:call G_QFixToggle(1)<CR>
imap <silent>          <F8> <ESC>:make!<CR>:call G_QFixToggle(1)<CR>
nmap          <unique> <F9> :!<UP>
imap          <unique> <F9> <ESC>:!<UP>
nmap <silent> <unique> <F11> <ESC>:tselect <C-R>=expand('<cword>')<CR><CR>
nmap <silent> <unique> <F12> <C-]>zz

" Single Key {{{2
nmap <silent> <unique> <Backspace> :call G_GotoEditor()<CR><C-O>zz
nmap <silent> <unique> \ :call G_GotoEditor()<CR><C-I>zz
nmap <silent> <unique> <Space> <C-D>
nmap <silent> <unique> qq :call G_QFixToggle(-1)<CR>
nmap <silent> <unique> q, :colder<CR>
nmap <silent> <unique> q. :cnewer<CR>
nnor <silent> <unique> p :call G_GoodP()<CR>
nmap <silent> <unique> - <C-U>
nmap <silent> <unique> ; zz
nmap <silent> <unique> ' 10[{kz<CR>
vmap <silent> <unique> + :Align =<CR>
"nmap <silent> <unique> [ :call G_QFixToggle(0)<CR>:call G_GotoEditor()<CR>:bp!<CR>
"nmap <silent> <unique> ] :call G_QFixToggle(0)<CR>:call G_GotoEditor()<CR>:bn!<CR>

" Shift+ {{{2
nnor <silent> <unique> H :call DevHelpCurrentWord()<CR>
nmap <silent>          W :exec "%s /\\s\\+$//ge"<CR>:w<CR>
nmap <silent> <unique> Q :qa!<CR>
nmap          <unique> <S-F7> :set formatoptions-=2mn<CR>
nmap                   <S-F8> :make! install DESTDIR=<UP>
nmap <silent> <unique> <S-F9> q:<UP>
nmap <silent> <unique> <S-F11> <ESC>:ptselect <C-R>=expand('<cword>')<CR><CR>

" Ctrl+ {{{2
nmap <silent> <unique> <C-Q> :q!<CR>
nmap <silent> <unique> <C-J> :call EasyMotion#JK(0, 0)<CR>
nmap <silent> <unique> <C-K> :call EasyMotion#JK(0, 1)<CR>
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
nmap <silent> <unique> <C-N> :call G_QFixToggle(0)<CR>:call G_GotoEditor()<CR>:bn!<CR>
nmap <silent> <unique> <C-P> :call G_QFixToggle(0)<CR>:call G_GotoEditor()<CR>:bp!<CR>
nmap <silent> <unique> <C-F8> :make! clean<CR>
nmap <silent> <unique> <C-F12> :!mkdir -p ~/__html__/%:h<CR>:TOhtml<CR>:w! ~/__html__/%<CR>:bw!<CR><C-L>

" Alt+ {{{2
if has("gui_running")
nmap <silent> <unique> <A-h> <C-W>h
nmap <silent> <unique> <A-j> <C-W>j
nmap <silent> <unique> <A-k> <C-W>k
nmap <silent> <unique> <A-l> <C-W>l
nmap <silent> <unique> <A-d> :bw<CR>
imap <silent> <unique> <A-b> <C-O>b
imap <silent> <unique> <A-f> <C-O>w
imap <silent> <unique> <A-d> <C-O>dw
else
nmap <silent> <unique> <ESC><ESC> :<CR>
nmap <silent> <unique> <ESC><Backspace> :call G_GotoEditor()<CR>:pop<CR>zz
nmap <silent> <unique> <ESC>\ :call G_GotoEditor()<CR>:tag<CR>zz
nmap <silent> <unique> <ESC>` :call G_GotoEditor()<CR>:e #<CR>
imap <silent> <unique> <ESC>` <ESC>:call G_GotoEditor()<CR>:e #<CR>a
nmap <silent> <unique> <ESC>h <C-W>h
nmap <silent> <unique> <ESC>j <C-W>j
nmap <silent> <unique> <ESC>k <C-W>k
nmap <silent> <unique> <ESC>l <C-W>l
nmap <silent> <unique> <ESC>d :bw<CR>
imap <silent> <unique> <ESC>b <C-O>b
imap <silent> <unique> <ESC>f <C-O>w
imap <silent> <unique> <ESC>d <C-O>dw
endif

" Leader+ , Leader char is ',' {{{2
nmap <silent> <unique> <Leader>1 :.diffget BASE<CR>:diffupdate<CR>
nmap <silent> <unique> <Leader>2 :.diffget LOCAL<CR>:diffupdate<CR>
nmap <silent> <unique> <Leader>3 :.diffget REMOTE<CR>:diffupdate<CR>
nmap <silent> <unique> <Leader>/ :call G_FindInFiles('single', 'y')<CR>
vmap <silent> <unique> <Leader>/ y:call G_FindInFiles('single', 'v')<CR>
nmap <silent> <unique> <Leader>? :call G_FindInFiles('single', 'n')<CR>
nmap <silent> <unique> <Leader>g :call G_FindInFiles('golbal', 'y')<CR>
vmap <silent> <unique> <Leader>g y:call G_FindInFiles('golbal', 'v')<CR>
nmap <silent> <unique> <Leader>G :call G_FindInFiles('golbal', 'n')<CR>
nmap <silent> <unique> <Leader>d :call G_CloseBuffer()<CR>
nmap <silent> <unique> <Leader>l :call <SID>ShowTabbar()<CR>
nmap <silent> <unique> <Leader>s :call <SID>CscopeFind('s', 'y')<CR>
nmap <silent> <unique> <Leader>c :call <SID>CscopeFind('c', 'y')<CR>
nmap <silent> <unique> <Leader>e :call <SID>CscopeFind('e', 'y')<CR>
nmap <silent> <unique> <Leader>S :call <SID>CscopeFind('s', 'n')<CR>
nmap <silent> <unique> <Leader>C :call <SID>CscopeFind('c', 'n')<CR>
nmap <silent> <unique> <Leader>E :call <SID>CscopeFind('e', 'n')<CR>
nmap <silent> <unique> <Leader>. :call G_QFixToggle(0)<CR>:GundoToggle<CR>

" Colon+, Colon char is ':' {{{2
command E :call Ranger()
command SS :SessionSave
command S :SessionList

command PP :!paps --landscape --font='monospace 8' --header --columns=2 % | ps2pdf - - | zathura -
command PPP :!paps --landscape --font='monospace 8' --header --columns=2 % | lp -o landscape -o sites=two-sided-long-edge -
" }}}1

" Autocmd {{{1
if has("autocmd")
  function! <SID>AC_ResetCursorPosition()
      if line("'\"") > 1 && line("'\"") <= line("$")
          exec "normal g`\"zz"
      endif
  endfunction

  function! <SID>AC_HighlightDirtySpace()
      syn match wtfSpace '　'
      hi link wtfSpace   SpecialKey
  endfunction

  function! <SID>AC_ChmodExecutable()
      if getline(1) =~ "^#!" && getline(1) =~ "/bin/"
          silent !chmod u+x %
          redraw!
      endif
  endfunction

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
    \ set path+=./

  autocmd Filetype java
    \ setlocal omnifunc=javacomplete#Complete

endif
" }}}

" 15# Plugins {{{1
call pathogen#infect('bundle')
call pathogen#helptags()

" TabBar 0.7-p3 : Plugin to add tab bar (derived from miniBufExplorer) {{{2
" http://www.vim.org/scripts/script.php?script_id=1338
"
" p1: Bf_SwitchTo
"     使用 <Esc>1..9 快捷键切换buffer时,跳转至编辑窗口
" p2: g:Tb_StatusLine
"     添加变量用户调整 TabBar 的状态栏信息
" p3: exec "cd ".expand('%:p:h')
"     即时更新当前目录
let Tb_UseSingleClick = 1 " 单击切换
let Tb_TabWrap = 1 " 允许跨行显示
let Tb_MaxSize = 3 "
let Tb_ModSelTarget = 1 " 跳转至编辑窗口
let Tb_SplitToEdge = 1 " 顶端，超越TabBar窗口
" 依赖 Powerline
"     第一个参数表示 Powerline/Matches.vim 中定义的列表序号(起始0)
"     第二个参数表示状态栏拥有焦点(1)还是没有焦点(0)
let Tb_StatusLine = '%!Pl#Statusline(9,0)'
if has("autocmd")
  autocmd BufWritePost *.c,*.cc,*.cpp,*.cxx,*.h,*.hh,*.hpp
    \ exec ":TbAup"
endif


" Tagbar eab0e : Display tags of the current file ordered by scope {{{2
" http://www.vim.org/scripts/script.php?script_id=3465
" https://github.com/majutsushi/tagbar
let g:tagbar_left = 1
let g:tagbar_width = 35
let g:tagbar_autofocus = 1
function! <SID>ShowTabbar()
    call G_GotoEditor()
    exec ":TagbarToggle"
endfunction


" SuperTab 1.6 : Do all your insert-mode completion with Tab {{{2
" http://www.vim.org/scripts/script.php?script_id=1643
" https://github.com/ervandew/supertab
let SuperTabCrMapping=0 " 该项和delimitMate的expand_cr选项冲突
let SuperTabRetainCompletionType=1
let SuperTabDefaultCompletionType="<C-X><C-N>"
let SuperTabMappingForward="<Tab>"
let SuperTabMappingBackward="<S-Tab>"


" Powerline @38bbfb8: The ultimate vim statusline utility.  {{{2
" http://www.vim.org/scripts/script.php?script_id=3881
" https://github.com/Lokaltog/vim-powerline
"
" 'fancy'符号依赖定制字体，详情参考
" https://github.com/Lokaltog/vim-powerline/wiki/Patched-fonts
"
" p1: matches \-TabBar\-
"     添加了一个匹配 -TabBar- 的主题
" p2: 'line.tot', '$COL %-2v'
"     使用可视列号
"     :help statusline
let g:Powerline_symbols = 'fancy'
set laststatus=2


" unite.vim 3.0 : Unite all sources {{{2
" http://www.vim.org/scripts/script.php?script_id=3396
" https://github.com/Shougo/unite.vim
let g:unite_source_file_mru_limit = 1000
let g:unite_cursor_line_highlight = 'TabLineSel'
if executable('ack-grep')
    let g:unite_source_grep_command = 'ack-grep'
    let g:unite_source_grep_default_opts = '--no-heading --no-color -a'
    let g:unite_source_grep_recursive_opt = ''
endif

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


" snipMate 0.83 : TextMate-style snippets for Vim {{{2
" http://www.vim.org/scripts/script.php?script_id=2540
" https://github.com/msanders/snipmate.vim
" nothing


" quickfixsigns 1.00 : Mark quickfix & location list items with signs {{{2
" http://www.vim.org/scripts/script.php?script_id=2584
" https://github.com/tomtom/quickfixsigns_vim
let quickfixsigns_blacklist_buffer = '^[_-].*[_-]$' "忽略 TabBar 和 -TabBar- 这两个 Buffer


" delimitMate.vim 2.6 : Provides auto-balancing and some expansions for parens, quotes, etc. {{{2
" http://www.vim.org/scripts/script.php?script_id=2754
" https://github.com/Raimondi/delimitMate
let delimitMate_autoclose = 1
let delimitMate_quotes = "\" ' `"
let delimitMate_nesting_quotes = []
let delimitMate_matchpairs = "(:),[:],{:},<:>"
let delimitMate_expand_cr = 1 " 该项和SuperTab的CrMapping选项冲突
let delimitMate_smart_quotes = 1
let delimitMate_balance_matchpairs = 1


" Gundo 2.3.0 : Visualize your undo tree {{{2
" http://www.vim.org/scripts/script.php?script_id=3304
" https://github.com/sjl/gundo.vim
let g:gundo_preview_height = 50
let g:gundo_preview_bottom = 1
let g:gundo_right = 1


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


" NrrwRgn 26 : A Narrow Region Plugin similar to Emacs {{{2
" http://www.vim.org/scripts/script.php?script_id=3075
" https://github.com/chrisbra/NrrwRgn
let g:nrrw_topbot_leftright = 'aboveleft'
let g:nrrw_rgn_wdth = 50


" autofmt 1.6 (2011-11-03): text formatting plugin {{{2
" http://www.vim.org/scripts/script.php?script_id=1939
set formatexpr=autofmt#japanese#formatexpr()


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
map  <Esc>[25~ <S-F3>
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
map  <Esc>[13^ <C-F3>
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
map! <Esc>[24$ <S-F12>
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

