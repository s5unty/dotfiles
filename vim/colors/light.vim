" Colour {{{
let g:colors_name="light"
set background=light
if exists("syntax_on")
  syntax reset
endif

if has("terminfo")
    set t_Co=256
else
    set t_Co=16
endif

hi clear

hi Normal           ctermfg=black

hi Comment          ctermfg=darkgreen                       cterm=italic

hi Constant         ctermfg=black
hi String           ctermfg=darkcyan
hi Character        ctermfg=darkcyan
hi Number           ctermfg=darkcyan
hi Boolean          ctermfg=darkcyan
hi Float            ctermfg=darkcyan

hi Identifier       ctermfg=black
hi Function         ctermfg=darkgrey                        cterm=bold

hi Statement        ctermfg=darkgrey                        cterm=bold
hi Conditional	    ctermfg=darkgrey                        cterm=bold
hi Repeat		    ctermfg=darkgrey                        cterm=bold
hi Label		    ctermfg=darkgrey                        cterm=bold
hi Operator         ctermfg=darkgrey                        cterm=bold
hi Keyword	        ctermfg=darkgrey                        cterm=bold
hi Exception	    ctermfg=black                           cterm=bold

hi PreProc          ctermfg=darkyellow
hi Include	        ctermfg=darkmagenta
hi Define		    ctermfg=darkmagenta
hi Macro		    ctermfg=darkmagenta
hi PreCondit	    ctermfg=darkmagenta

hi Type             ctermfg=darkgrey                        cterm=bold
hi StorageClass	    ctermfg=black                           cterm=bold
hi Structure	    ctermfg=black                           cterm=bold
hi Typedef	        ctermfg=black                           cterm=bold

hi Special          ctermfg=darkyellow
hi SpecialChar      ctermfg=darkyellow
hi Tag              ctermfg=darkred                         cterm=bold,underline
hi Delimiter        ctermfg=darkyellow
hi SpecialComment   ctermfg=darkgreen                       cterm=bold,underline
hi Debug            ctermfg=darkred

hi Underlined       ctermfg=NONE                            cterm=underline

hi Ignore           ctermfg=lightgrey

hi Error            ctermfg=white       ctermbg=darkred     cterm=bold

hi Todo             ctermfg=black       ctermbg=yellow      cterm=bold

hi Pmenu            ctermfg=black       ctermbg=magenta
hi PmenuSel         ctermfg=yellow      ctermbg=darkblue    cterm=bold
hi NonText          ctermfg=magenta
hi Directory        ctermfg=darkblue
hi ErrorMsg         ctermfg=white       ctermbg=darkred     cterm=none
hi WarningMsg       ctermfg=white       ctermbg=black       cterm=none
hi MatchParen       ctermfg=black       ctermbg=cyan        cterm=italic
hi VertSplit        ctermfg=black       ctermbg=lightgrey   cterm=none
hi StatusLine       ctermfg=black       ctermbg=lightgrey   cterm=none
hi StatusLineNC     ctermfg=black       ctermbg=lightgrey   cterm=none
hi IncSearch        ctermfg=white       ctermbg=darkblue    cterm=none
hi Search           ctermfg=black       ctermbg=yellow      cterm=none
hi Question         ctermfg=white       ctermbg=darkgrey
hi LineNr           ctermfg=grey                            cterm=italic
hi DiffAdd          ctermfg=darkgreen   ctermbg=lightgrey   cterm=none
hi DiffChange       ctermfg=NONE        ctermbg=lightgrey   cterm=none
hi DiffDelete       ctermfg=darkred     ctermbg=lightgrey   cterm=none
hi DiffText         ctermfg=NONE        ctermbg=yellow      cterm=none
hi Folded           ctermfg=grey        ctermbg=NONE        cterm=bold,italic
hi FoldColumn       ctermfg=darkgrey    ctermbg=NONE
hi SignColumn       ctermfg=white       ctermbg=NONE
hi MoreMsg          ctermfg=white       ctermbg=darkgrey
hi ModeMsg          ctermfg=white       ctermbg=darkgrey    cterm=none
hi Title            ctermfg=black       ctermbg=yellow
hi Visual           ctermfg=white       ctermbg=darkblue
hi WildMenu         ctermfg=white       ctermbg=black
hi Cursorline       ctermfg=NONE        ctermbg=yellow      cterm=none
" link - diff/patch
hi def link diffAdded   DiffAdd
hi def link diffRemoved DiffDelete
hi def link diffFile    DiffText
hi def link diffSubname String
hi def link diffLine    String
" vimwiki
hi VimwikiItalic        ctermfg=darkyellow                  cterm=italic
hi VimwikiDelText       ctermfg=darkgray
hi VimwikiList          ctermfg=green
" taglist
hi MyTagListTagName     ctermfg=darkgrey    ctermbg=white   cterm=reverse
hi MyTagListFileName    ctermfg=darkgrey    ctermbg=NONE    cterm=italic
hi MyTagListTitle       ctermfg=black       ctermbg=NONE    cterm=bold
hi MyTagListTagScope    ctermfg=NONE        ctermbg=NONE
" tabbar
hi Tb_Normal            ctermfg=darkgrey    ctermbg=NONE
hi Tb_Changed           ctermfg=red         ctermbg=NONE
hi Tb_Readonly          ctermfg=green       ctermbg=NONE
hi Tb_VisibleNormal     ctermfg=white       ctermbg=darkgrey
hi Tb_VisibleChanged    ctermfg=black       ctermbg=red
hi Tb_VisibleReadonly   ctermfg=black       ctermbg=green
" }}}
