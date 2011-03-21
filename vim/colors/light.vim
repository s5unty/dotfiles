" Colour {{{
let g:colors_name="pattern"
set background=light

" First remove all existing highlighting.
hi clear
if exists("syntax_on")
  syntax reset
endif

" colorname  dark
" yellow #cdcd00
" darkgreen #458b00
" darkcyan #00c5cd
" darkred #ee2c2c
" darkmagenta #cd3278
" darkblue #1874cd
" darkgrey #404040
"
" magenta #ff69b4
" red #ff4040
" cyan #00ffff
" blue #6495ed
" green #00ee00

hi Comment          ctermfg=darkgreen                       cterm=italic        guifg=#458b00                           gui=italic
hi Constant         ctermfg=darkcyan                                            guifg=#00c5cd
hi Special          ctermfg=darkred                                             guifg=#ee2c2c
hi PreProc          ctermfg=darkmagenta                                         guifg=#cd3278
hi Statement        ctermfg=darkblue                                            guifg=#1874cd                           gui=none
hi Type             ctermfg=darkblue                                            guifg=#1874cd                           gui=none
hi Underlined       ctermfg=NONE        ctermbg=NONE        cterm=underline     guifg=NONE          guibg=NONE          gui=underline
hi Ignore           ctermfg=darkgrey    ctermbg=NONE                            guifg=#404040       guibg=NONE
hi Error            ctermfg=black       ctermbg=darkred     cterm=bold          guifg=black         guibg=#ee2c2c       gui=bold
hi Todo             ctermfg=white       ctermbg=darkgreen   cterm=bold          guifg=white         guibg=#458b00       gui=bold
hi String           ctermfg=darkcyan                                            guifg=#00c5cd
hi Identifier       ctermfg=grey        ctermbg=NONE                            guifg=grey          guibg=NONE
hi Normal           ctermfg=NONE        ctermbg=NONE                            guifg=#cdcd00       guibg=#222222
hi Pmenu            ctermfg=black       ctermbg=magenta                         guifg=black         guibg=#ff69b4
hi PmenuSel         ctermfg=yellow      ctermbg=darkblue    cterm=bold          guifg=#cdcd00       guibg=#1874cd       gui=bold
hi SpecialKey       ctermfg=white       ctermbg=red         cterm=underline     guifg=white         guibg=#ff4040       gui=underline
hi NonText          ctermfg=magenta     ctermbg=NONE                            guifg=#ff69b4       guibg=NONE
hi Directory        ctermfg=darkblue    ctermbg=NONE                            guifg=#1874cd       guibg=NONE
hi ErrorMsg         ctermfg=darkred     ctermbg=NONE                            guifg=#ee2c2c       guibg=NONE
hi WarningMsg       ctermfg=white       ctermbg=NONE                            guifg=white         guibg=NONE
hi MatchParen       ctermfg=black       ctermbg=cyan        cterm=italic        guifg=black         guibg=#00ffff       gui=italic
hi VertSplit        ctermfg=darkgrey    ctermbg=black                           guifg=white         guibg=NONE          gui=bold
hi StatusLine       ctermfg=darkgrey    ctermbg=black                           guifg=white         guibg=black
hi StatusLineNC     ctermfg=darkgrey    ctermbg=black                           guifg=white         guibg=black
hi IncSearch        ctermfg=darkblue    ctermbg=white                           guifg=#6495ed       guibg=white
hi Search           ctermfg=red         ctermbg=NONE        cterm=bold          guifg=#ff4040       guibg=NONE          gui=bold
hi Question         ctermfg=magenta                                             guifg=#ff69b4
hi LineNr           ctermfg=darkgreen                       cterm=italic        guifg=#458b00       guibg=NONE          gui=italic
hi DiffAdd          ctermfg=darkgreen   ctermbg=NONE        cterm=bold          guifg=#458b00       guibg=NONE          gui=bold
hi DiffChange       ctermfg=white       ctermbg=NONE                            guifg=white         guibg=NONE
hi DiffDelete       ctermfg=darkred     ctermbg=NONE                            guifg=#ee2c2c       guibg=NONE
hi DiffText         ctermfg=NONE        ctermbg=NONE        cterm=bold          guifg=NONE          guibg=NONE          gui=bold
hi Folded           ctermfg=green       ctermbg=NONE        cterm=italic        guifg=#00ee00       guibg=NONE          gui=italic
hi FoldColumn       ctermfg=darkgreen   ctermbg=NONE                            guifg=#458b00       guibg=NONE
hi SignColumn       ctermfg=white       ctermbg=NONE                            guifg=white         guibg=NONE
hi MoreMsg          ctermfg=darkgreen                                           guifg=#458b00
hi ModeMsg          ctermfg=darkred                                             guifg=#ee2c2c
hi Title            ctermfg=darkblue                                            guifg=#1874cd
hi Visual           ctermfg=white       ctermbg=darkblue                        guifg=white         guibg=#1874cd
hi WildMenu         ctermfg=white       ctermbg=black                           guifg=white         guibg=#cdcd00
" link - diff/patch
hi def link diffAdded   DiffAdd
hi def link diffRemoved DiffDelete
hi def link diffFile    DiffText
hi def link diffSubname String
hi def link diffLine    String
" vimwiki
hi VimwikiItalic        ctermfg=darkyellow                  cterm=italic                                                gui=italic
hi VimwikiDelText       ctermfg=darkgray                                        guifg=black
hi VimwikiList          ctermfg=green                                           guifg=#00ee00
" taglist
hi MyTagListTagName     ctermfg=darkgrey    ctermbg=white   cterm=reverse       guifg=NONE          guibg=NONE          gui=reverse
hi MyTagListFileName    ctermfg=darkgreen   ctermbg=NONE    cterm=italic        guifg=#458b00       guibg=NONE          gui=italic
hi MyTagListTitle       ctermfg=black       ctermbg=NONE    cterm=bold          guifg=#404040       guibg=NONE          gui=bold
hi MyTagListTagScope    ctermfg=NONE        ctermbg=NONE                        guifg=NONE          guibg=NONE
" tabbar
hi Tb_Normal            ctermfg=darkgreen   ctermbg=NONE                        guifg=#458b00       guibg=NONE
hi Tb_Changed           ctermfg=black       ctermbg=red                         guifg=#ff4040       guibg=NONE
hi Tb_VisibleNormal     ctermfg=white       ctermbg=darkgrey                   guifg=black         guibg=white
hi Tb_VisibleChanged    ctermfg=red         ctermbg=white                       guifg=#ff4040       guibg=white
hi Tb_Readonly          ctermfg=green       ctermbg=NONE                        guifg=#00ee00       guibg=NONE
hi Tb_VisibleReadonly   ctermfg=black       ctermbg=green                       guifg=black         guibg=#00ee00
" }}}
