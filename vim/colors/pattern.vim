" Colour {{{
let g:colors_name="pattern"

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
hi DiffAdd          ctermfg=darkgreen   ctermbg=NONE		cterm=bold          guifg=darkgreen     guibg=NONE
hi DiffChange       ctermfg=white       ctermbg=NONE        cterm=bold          guifg=lightblue     guibg=NONE
hi DiffDelete       ctermfg=darkred     ctermbg=NONE                            guifg=darkred       guibg=NONE
hi DiffText         ctermfg=NONE        ctermbg=NONE        cterm=bold          guifg=NONE          guibg=NONE          gui=bold
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
hi MyTagListTagName     ctermfg=NONE        ctermbg=NONE    cterm=reverse
hi MyTagListFileName    ctermfg=darkgreen   ctermbg=NONE    cterm=italic
hi MyTagListTitle       ctermfg=grey        ctermbg=NONE    cterm=bold
hi MyTagListTagScope    ctermfg=NONE        ctermbg=NONE
" tabbar
hi Tb_Normal            ctermfg=darkgreen   ctermbg=NONE
hi Tb_Changed           ctermfg=red         ctermbg=NONE
hi Tb_VisibleNormal     ctermfg=black       ctermbg=white
hi Tb_VisibleChanged    ctermfg=red         ctermbg=white
hi Tb_Readonly          ctermfg=green       ctermbg=NONE
hi Tb_VisibleReadonly   ctermfg=black       ctermbg=green
" }}}
