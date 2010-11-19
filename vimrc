" General {{{1
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,chinese,taiwan,japan,korea,latin1
set termencoding=utf-8
set fileformats=unix,dos
set mouse=a " 开启鼠标支持
set noexpandtab " TAB is hard
set tabstop=4 " TAB 的宽度
set shiftwidth=4 " 缩进的宽度
set softtabstop=4
set clipboard=unnamed " 使用系统剪贴板
set backspace=indent,eol,start " 退格
set foldmethod=marker
set ignorecase " 搜索忽略大小写
set expandtab
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
set winaltkeys=no
set cinoptions=:0,g0,t0,(0
set timeoutlen=500
set autoread
set autowrite
set wildignore=*.o,*.obj,*.orig
set wildmenu
set wildmode=longest:full,list:full
 
if has("gui_running")
    set guioptions-=m
    set guioptions-=T
    set imactivatekey=C-space " GVim 中文无缝输入
endif

if has("win32")
    au GUIEnter * simalt ~x
    language messages zh_CN.UTF-8
    set grepprg=findstr\ /n
    set guifont=Envy_Code_R:h10
    set guifontwide=NSimsun:h10.5
    set shell=cmd.exe
else
    set guifont=Envy\ Code\ R\ 10
    set guifontwide=WenQuanYi\ Zen\ Hei\ Sharp\ 10
    set makeprg=make\ -j2
    set grepprg=ack-grep
    set shell=bash\ -x\ -c
endif

let mapleader=","
let html_dynamic_folds=1
let c_space_errors=1
let sh_minlines = 500
syn enable " 语法高亮
filetype plugin indent on
color pattern

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
        exec ":silent TlistSync"
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
" }}}

" Key bindings {{{1
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
set pastetoggle=<F4>
nmap          <unique> <F5> :!git difftool --tool=vimdiff -y HEAD -- %<LEFT><LEFT><LEFT><LEFT><LEFT>
nmap <silent> <unique> <F6> :ConqueTermSplit zsh<CR>
nmap          <unique> <F7> :set formatoptions+=2mM<CR>
imap          <unique> <F7> <Esc>:set formatoptions+=2mM<CR><CR>
nmap <silent>          <F8> :make!<CR>:call G_QFixToggle(1)<CR>
imap <silent>          <F8> <ESC>:make!<CR>:call G_QFixToggle(1)<CR>
nmap          <unique> <F9> :!<UP>
imap          <unique> <F9> <ESC>:!<UP>
nmap <silent> <unique> <F10> :Mru<CR>
imap <silent> <unique> <F10> <ESC>:Mru<CR>
nmap <silent> <unique> <F11> g]
vmap <silent> <unique> <F11> g]
nmap <silent> <unique> <F12> <C-]>zz
vmap <silent> <unique> <F12> <C-]>zz

" Single Key {{{2
nmap <silent> <unique> <Backspace> :call G_GotoEditor()<CR><C-O>zz
nmap <silent> <unique> \ :call G_GotoEditor()<CR><C-I>zz
nmap <silent> <unique> <Space> <C-D>
nmap <silent> <unique> qq :call G_QFixToggle(-1)<CR>
nnor <silent> <unique> p :call G_GoodP()<CR>
nmap <silent> <unique> - <C-U>
nmap <silent> <unique> ; zz
nmap <silent> <unique> ' 10[{kz<CR>
vmap <silent> <unique> + :Align =<CR>
"nmap <silent> <unique> [ :call G_QFixToggle(0)<CR>:call G_GotoEditor()<CR>:bp!<CR>
"nmap <silent> <unique> ] :call G_QFixToggle(0)<CR>:call G_GotoEditor()<CR>:bn!<CR>

" Shift+ {{{2
nnor <silent> <unique> H :call DevHelpCurrentWord()<CR>
nmap <silent> <unique> W :exec "%s /\\s\\+$//ge"<CR>:w<CR>
nmap <silent> <unique> Q :q<CR>
nmap          <unique> <S-F8> :make! install DESTDIR=<UP>
nmap <silent> <unique> <S-F9> q:<UP>

" Ctrl+ {{{2
nmap <silent> <unique> <C-Q> :qa!<CR>
imap <silent> <unique> <C-Q> <ESC>;
imap <silent> <unique> <C-W> <SPACE><ESC>dbs
imap <silent> <unique> <C-F> <ESC>ea
imap <silent> <unique> <C-B> <C-O>b
imap <silent> <unique> <C-D> <C-O>de
imap <silent> <unique> <C-H> <Left>
imap <silent> <unique> <C-J> <Down>
imap <silent> <unique> <C-K> <Up>
imap <silent> <unique> <C-L> <Right>
imap <silent> <unique> <C-U> <C-O>u
nmap <silent> <unique> <C-N> :call G_QFixToggle(0)<CR>:call G_GotoEditor()<CR>:bn!<CR>
nmap <silent> <unique> <C-P> :call G_QFixToggle(0)<CR>:call G_GotoEditor()<CR>:bp!<CR>
nmap <silent> <unique> <C-F8> :make! clean<CR>

" Alt+ {{{2
if has("gui_running")
nmap <silent> <unique> <A-h> <C-W>h
nmap <silent> <unique> <A-j> <C-W>j
nmap <silent> <unique> <A-k> <C-W>k
nmap <silent> <unique> <A-l> <C-W>l
nmap <silent> <unique> <A-d> :CalendarH<CR>
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
nmap <silent> <unique> <ESC>d :CalendarH<CR>
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
nmap <silent> <unique> <Leader>l :call <SID>ShowTaglist()<CR>
nmap <silent> <unique> <Leader>s :call <SID>CscopeFind('s', 'y')<CR>
nmap <silent> <unique> <Leader>c :call <SID>CscopeFind('c', 'y')<CR>
nmap <silent> <unique> <Leader>e :call <SID>CscopeFind('e', 'y')<CR>
nmap <silent> <unique> <Leader>S :call <SID>CscopeFind('s', 'n')<CR>
nmap <silent> <unique> <Leader>C :call <SID>CscopeFind('c', 'n')<CR>
nmap <silent> <unique> <Leader>E :call <SID>CscopeFind('e', 'n')<CR>
nmap <silent> <unique> <Leader>. :call <SID>VimwikiGoMain()<CR>

" Colon+, Colon char is ':' {{{2
command W :w !sudo tee %

" }}}1

" Autocmd {{{1
if has("autocmd")
  function! <SID>AC_ResetCursorPosition()
      if line("'\"") > 0 && line("'\"") <= line("$")
          exec "normal g`\"zz"
      endif
  endfunction

  function! <SID>AC_ChmodExecutable()
      if getline(1) =~ "^#!" && getline(1) =~ "/bin/"
          silent !chmod u+x %
          redraw!
      endif
  endfunction

  " 每次访问文件时都把光标放置在上次离开的位置
  autocmd BufWinEnter *
    \ call <SID>AC_ResetCursorPosition()

  " 让 checkpath 找到相关文件，便于 [I 正常工作
  autocmd BufEnter,WinEnter *.c,*.cc,*.cpp,*.cxx,*.h,*.hh,*.hpp
    \ set path+=./

  augroup markdown
      au! BufRead,BufNewFile *.asciidoc setfiletype asciidoc
  augroup END

  autocmd BufWritePost *
    \ call <SID>AC_ChmodExecutable()
endif
" }}}

" 12# Plugins {{{1
" mru.vim 3.3-p2 : Plugin to manage Most Recently Used (MRU) files {{{2
" http://www.vim.org/scripts/script.php?script_id=521
"
" p1: @@529@@
"             let split_window = 0
" p2: @@575@@
"             let fnames = reverse(fnames)
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
let Tlist_Process_File_Always = 0
let Tlist_Use_Horiz_Window = 0
let Tlist_Sort_Type = "name"
let tlist_c_settings = 'c;p:prototype;f:implementation'
let tlist_cpp_settings = 'c++;c:object;p:prototype;f:implementation'

function! <SID>ShowTaglist()
    if exists("g:loaded_taglist")
        call G_GotoEditor()
        exec "TlistToggle"
    endif
endfunction

" TabBar 0.7-p2 : Plugin to add tab bar (derived from miniBufExplorer) {{{2
" http://www.vim.org/scripts/script.php?script_id=1338
"
" p1: Bf_SwitchTo
"     使用 <Esc>1..9 快捷键切换buffer时,跳转至编辑窗口
" p2: g:Tb_StatusLine
"     添加变量用户调整 TabBar 的状态栏信息
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


" Cscope : Interactively examine a C program source {{{2
" http://cscope.sourceforge.net/
set tag=.cscope/cscope.tags,~/.tags;
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

" vimwiki 1.1.1: Personal Wiki for Vim {{{2
" http://code.google.com/p/vimwiki/
let vw_home = '/sun/wiki/'
"let vw_home = 'scp://www-data@du1abadd.org//sun/dokuwiki/data/pages/'
let vw_journal = {}
let vw_android = {}
let g:vimwiki_list = [vw_journal, vw_android]
let g:vimwiki_stripsym = '_' " 非法符号转换为空格
let g:vimwiki_badsyms = ' '  " 删除文件名中的空格
let g:vimwiki_camel_case = 0 " 禁用驼峰格式
let g:vimwiki_use_calendar = 1

let vw_journal.syntax = 'doku'
let vw_journal.index = 'journal'
let vw_journal.ext = '.txt'
let vw_journal.path = vw_home.'journal'
let vw_journal.diary_index = 'journal'
let vw_journal.diary_rel_path = ''
let vw_journal.diary_link_count = 10

let vw_android.syntax = 'doku'
let vw_android.index = 'android'
let vw_android.ext = '.txt'
let vw_android.path = vw_home.'android'

" snipMate 0.83 : TextMate-style snippets for Vim {{{2
" http://www.vim.org/scripts/script.php?script_id=2540
" nothing

" quickfixsigns 0.5 : Mark quickfix & location list items with signs {{{2
" http://www.vim.org/scripts/script.php?script_id=2584
set lazyredraw

" sessionman.vim 1.04-p1 : Vim session manager {{{2
" http://www.vim.org/scripts/script.php?script_id=2010
"
" p1: s:OpenSession
"     打开 Session 前 TbStop, 之后 TbStart. 否则布局大乱
"     打开 Session 后使用 color pattern 自定义的颜色方案

" surround.vim 1.90 : Delete/change/add parentheses/quotes/XML-tags/much more with ease {{{2
" http://www.vim.org/scripts/script.php?script_id=1697
" nothing
"
" 在 normal mode 下按 ysiwb 或者 cs@1@2
" 在 visual mode 下选中一个字符串按 sb, b | B | " | ' | { | > | [ | ] 

" Conque Shell 1.1 : Run interactive commands inside a Vim buffer {{{2
" http://www.vim.org/scripts/script.php?script_id=2771
let ConqueTerm_EscKey = '<Esc>'
let ConqueTerm_Color = 1
let ConqueTerm_TERM = 'rxvt-unicode'
let ConqueTerm_ReadUnfocused = 1
let ConqueTerm_CWInsert = 0

" calendar.vim 2.2 : Calendar {{{2
" http://www.vim.org/scripts/script.php?script_id=52
let g:calendar_monday = 1
let g:calendar_mark = 'left-fit'
let g:calendar_focus_today = 1


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
