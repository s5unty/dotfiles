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
set clipboard^=unnamed,unnamedplus " 使用系统剪贴板
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
set showcmd " 右下方显示按键序列
set winaltkeys=no
set cinoptions=:0
set timeoutlen=500
set ttimeoutlen=50
set timeout
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
set rtp+=/usr/bin/fzf
set guicursor=a:blinkon100 " 让光标抖起来
set shell=/usr/bin/zsh
set background=light
set termguicolors
set undodir=~/.local/share/nvim/undo/
set undofile
set signcolumn=number " 提示符嵌在行号栏
" set inccommand=split " 好像是 NeoVim 特有的
" set shortmess-=F " https://github.com/natebosch/vim-lsc
" syn on " 语法高亮改用 treesitter

if has("gui_running")
    set guioptions-=m
    set guioptions-=T
endif

if has("win32") || has("win64")
    au GUIEnter * simalt ~x
    language messages zh_CN.UTF-8
    set grepprg=findstr\ /n
    " set guifont=Envy_Code_R_For_Powerline:h10
    " set guifontwide=NSimsun:h10.5
    set shell=cmd.exe
    set directory=$TMP
else
    set guifont=EnvyCodeR\ Nerd\ Font
    " set guifont=Envy\ Code\ R\ For\ Powerline\ 10
    " set guifontwide=WenQuanYi\ Micro\ Hei\ 10
    set makeprg=make\ -j2
    set grepprg=ag\ --vimgrep\ $*
    set grepformat=%f:%l:%c:%m
    set shell=bash\ -x\ -c
    set directory=/tmp
endif

" 用全角显示『○』、『△』、『□』这样的特殊字符
" East Asian Ambiguous Width:
" http://www.unicode.org/reports/tr11/
" http://lists.debian.or.jp/debian-devel/200703/msg00038.html
" http://sakurapup.browserloadofcoolness.com/viewtopic.php?f=13&t=2
" http://du1abadd.org/debian/UTF-8-EAW-FULLWIDTH.gz
" https://github.com/hamano/locale-eaw/blob/master/README.md
" https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.narrow_symbols
if exists('&ambw')
"   set ambiwidth=double
    call setcellwidths([
      \ [0x2605, 0x2606, 2],
      \ [0x25cb, 0x25cf, 2],
      \ [0x203b, 0x203b, 2],
      \ [0x25b3, 0x25b3, 2],
      \ [0x25a1, 0x25a1, 2],
      \ [0x2460, 0x2469, 2],
      \ ])
endif

let html_dynamic_folds=1
let c_space_errors=1
let sh_minlines = 100
filetype plugin indent on
" }}}1

" Old-school {{{1
" 中英文之间自动插入空格
" ref: https://github.com/yuweijun/vim-space
function! SpaceAddBetweenEnglishChinese() range
    for linenum in range(line("'<"), line("'>"))
        let oldline = getline(linenum)
        let newline = substitute(oldline, '\([\u4e00-\u9fa5]\)\(\w\)', '\1 \2', 'g')
        let newline = substitute(newline, '\(\w\)\([\u4e00-\u9fa5]\)', '\1 \2', 'g')
        call setline(linenum, newline)
    endfor
endfunction

" Space键 翻页/打开折叠
function! G_GoodSpace()
    if foldclosed('.') != -1
        normal zO
    else
        exec "normal \<C-D>"
        normal zz
    endif
endfunction

" 0键在行首与行顶间交替，顺便打开折叠
function! G_Good0()
    if foldclosed('.') != -1
        normal zO
    elseif ! exists("b:is_pressed0")
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

    exec "normal /" . name . "\<CR>"
    normal d
    call G_GotoEditor()
endfunction

if has("autocmd")
    function! <SID>AC_ResetCursorPosition()
        if line("'\"") > 1 && line("'\"") <= line("$")
            exec "normal g`\"zz"
        endif
    endfunction

    function! <SID>AC_HighlightDirtySpace()
        highlight link wtfSpace SpellRare
        match wtfSpace /[　 ]/
    endfunction

    function! <SID>AC_ChmodExecutable()
        if getline(1) =~ "^#!" && getline(1) =~ "/bin/"
            silent !chmod u+x %
            redraw!
        endif
    endfunction

    autocmd VimResized *
                \ redrawstatus!

    " 自动关闭预览窗口
    autocmd InsertLeave *
                \ if pumvisible() == 0 | pclose | endif

    " 这样加快输入法自动切换时的体感速度
    autocmd InsertEnter * set timeoutlen=50
    autocmd InsertLeave * set timeoutlen=500

    " 每次访问文件时都把光标放置在上次离开的位置
    autocmd BufReadPost *
                \ call <SID>AC_ResetCursorPosition()

    " 每次加载文件时都把全角空格'　'高亮显示出来
    autocmd BufReadPost *
                \ call <SID>AC_HighlightDirtySpace()

    " 写测试脚本的时候自动更新为可执行格式
    autocmd BufWritePost *
                \ call <SID>AC_ChmodExecutable()
endif
" }}}1

" Key maps {{{1
" Mouse Bindings {{{2
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
if has('nvim')
nmap          <unique> <F5> :terminal git difftool --tool=vimdiff -y HEAD -- %<LEFT><LEFT><LEFT><LEFT><LEFT>
else
nmap          <unique> <F5> :!git difftool --tool=vimdiff -y HEAD -- %<LEFT><LEFT><LEFT><LEFT><LEFT>
endif
nmap <silent> <unique> <F6> :Inspect<CR>
nmap          <unique> <F7> :set formatoptions+=12mnM<CR>
nmap <silent> <unique> <F8> :make!<CR>
nmap <silent> <unique> <F9> :History<CR>
nmap <silent> <unique> <F10> :<CR>
nmap <silent> <unique> <F11> <ESC>:tselect <C-R>=expand('<cword>')<CR><CR>
nmap <silent> <unique> <F12> <C-]>zz

" Single Key {{{2
nmap <silent> <unique> <Backspace> :call G_GotoEditor()<CR><C-O>zz
nmap <silent> <unique> \ :call G_GotoEditor()<CR><C-I>zz
nmap <silent> <unique> <Space> :call G_GoodSpace()<CR>
nmap <silent> <unique> - <C-U>
nmap <silent> <unique> ; zz
nmap <silent> <unique> ' $
vmap <silent> <unique> + :VisSum<CR>
nmap <silent> <unique> 0 :call G_Good0()<CR>
vmap <silent> <unique> ; :call SpaceAddBetweenEnglishChinese()<CR>

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
imap <silent> <unique> <C-Q> <ESC><ESC>;
imap <silent> <unique> <C-E> <C-O>$
imap <silent> <unique> <C-A> <C-O>^
imap <silent> <unique> <C-D> <C-O>x
imap <silent> <unique> <C-K> <C-O>d$
imap <silent> <unique> <C-Y> <C-O>u<C-O>$
nmap <silent> <unique> <C-F8> :make! clean<CR>
nmap <silent> <unique> <C-F12> :!mkdir -p ~/__html__/%:h<CR>:TOhtml<CR>:w! ~/__html__/%<CR>:bw!<CR><C-L>

" Alt+ {{{2
if has("gui_running")
imap <silent> <unique> <A-b> <C-O>b
imap <silent> <unique> <A-f> <C-O>w
imap <silent> <unique> <A-d> <C-O>dw
elseif &term == "nvim"
nmap <silent> <unique> <M-Backspace> :call G_GotoEditor()<CR>:pop<CR>zz
nmap <silent> <unique> <M-\> :call G_GotoEditor()<CR>:tag<CR>zz
nmap <silent> <unique> <M-`> :call G_GotoEditor()<CR>:e #<CR>
imap <silent> <unique> <M-`> <ESC>:call G_GotoEditor()<CR>:e #<CR>a
imap <silent> <unique> <M-b> <C-O>b
imap <silent> <unique> <M-f> <C-O>w
imap <silent> <unique> <M-d> <C-O>dw
else
nmap <silent> <unique> <Esc><Backspace> :call G_GotoEditor()<CR>:pop<CR>zz
nmap <silent> <unique> <Esc>\ :call G_GotoEditor()<CR>:tag<CR>zz
nmap <silent> <unique> <Esc>` :call G_GotoEditor()<CR>:e #<CR>
imap <silent> <unique> <Esc>` <ESC>:call G_GotoEditor()<CR>:e #<CR>a
imap <silent> <unique> <Esc>b <C-O>b
imap <silent> <unique> <Esc>f <C-O>w
imap <silent> <unique> <Esc>d <C-O>dw
endif

" Leader+ , Leader char is ';' {{{2
let mapleader=' '
let maplocalleader=','
nmap <silent> <unique> <Leader>q :q<CR>
nmap <silent> <unique> <Leader>h <C-W>h
nmap <silent> <unique> <Leader>j <C-W>j
nmap <silent> <unique> <Leader>k <C-W>k
nmap <silent> <unique> <Leader>l <C-W>l
nmap <silent> <unique> <Leader>1 :.diffget BASE<CR>:diffupdate<CR>
nmap <silent> <unique> <Leader>2 :.diffget LOCAL<CR>:diffupdate<CR>
nmap <silent> <unique> <Leader>3 :.diffget REMOTE<CR>:diffupdate<CR>
nmap <silent> <unique> <Leader>d :call G_CloseBuffer()<CR>
nmap <silent> <unique> <Leader>a :GundoToggle<CR>
vmap <silent> <unique> <Leader>a <Plug>VimSumVisual

" Colon+, Colon char is ':' {{{2
command W  :w !sudo tee %
command E  :call Ranger()<CR>
command H  :History:
command A  :Ag
command F  :Files
command PP :!paps --landscape --font='monospace 8' --header --columns=2 % | ps2pdf - - | zathura -
command PPP :!paps --landscape --font='monospace 8' --header --columns=2 % | lp -o landscape -o sites=two-sided-long-edge -

" }}}1

" Plugged {{{1
call plug#begin('~/.config/nvim/bundles')
    " 在模式间切换输入法
    Plug 'alohaia/fcitx.nvim'
    " 自动补全括号引号
    Plug 'windwp/nvim-autopairs'
    " 著名的 Powerline
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'nvim-tree/nvim-web-devicons'
    " 侧边导航(目录、缓存区、标记)
    Plug 'nvim-lua/plenary.nvim'
    Plug 'MunifTanjim/nui.nvim'
    Plug 'nvim-neo-tree/neo-tree.nvim', { 'branch': 'v3.x' }
    " 习惯了 buffer
    Plug 'akinsho/bufferline.nvim'
    " 为什么我没这种需求
    Plug 'kylechui/nvim-surround'
    " 数值的递增递减
    Plug 'vim-scripts/VisIncr'
    " 数值的求和
    Plug 'emugel/vim-sum'
    " 光标下的单词高亮
    Plug 'RRethy/vim-illuminate'
    " 增量的模糊查询 [o]fzf [x]denite
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    " 预览窗的快捷键
    Plug 'ronakg/quickr-preview.vim'
    " 补全框架(代码、模板、路径等)
    Plug 'neovim/nvim-lspconfig'  " Collection of configurations for built-in LSP client
    Plug 'hrsh7th/nvim-cmp'       " Autocompletion plugin
    Plug 'onsails/lspkind-nvim'   " VSCode-like pictograms
    Plug 'hrsh7th/cmp-nvim-lsp'   " LSP source for nvim-cmp
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    " 语法框架(高亮、重构、编辑等)
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-context'
    Plug 'nvim-treesitter/nvim-treesitter-refactor'
    " 模板引擎 [o]snippy [x]LuaSnip [x]vsnip
    Plug 'dcampos/nvim-snippy'
    Plug 'dcampos/cmp-snippy'
    " 大纲导航
    Plug 'stevearc/aerial.nvim'
    " 主题配色
    Plug 'Th3Whit3Wolf/one-nvim'
    " 语言(Dart)
    Plug 'dart-lang/dart-vim-plugin'
    " 语言(Elvish)
    Plug 'chlorm/vim-syntax-elvish'
call plug#end()


" Syntax highlighting for Dart in Vim {{{2
" https://github.com/dart-lang/dart-vim-plugin
let g:dart_style_guide = 2
let g:dart_format_on_save = v:false


" Quickly preview Quickfix results in vim without opening the file {{{2
" https://github.com/ronakg/quickr-preview.vim
let g:quickr_preview_keymaps = 0
let g:quickr_preview_exit_on_enter = 1
function! QuickfixMapping()
    nmap <silent> <buffer> p <plug>(quickr_preview)
    nmap <silent> <buffer> q <plug>(quickr_preview_qf_close)
endfunction
augroup quickfix_group
    autocmd!
    autocmd filetype qf call QuickfixMapping()
augroup END


" An Atom One inspired dark and light colorscheme for neovim. {{{2
" https://github.com/Th3Whit3Wolf/one-nvim
colorscheme one-nvim
hi Todo guibg=yellow


" }}}1

lua require("_init")

