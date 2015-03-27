" Inspired by donbass.vim by Dmitry Maluka <dmitrymaluka@gmail.com>
" donbass.vim 0.4 : Finely tuned, 256 color, light-grey background colorscheme
" http://www.vim.org/scripts/script.php?script_id=2730

set t_Co=256
set background=light
hi clear
if exists("syntax_on")
    syntax reset
endif

let g:colors_name="light256"

" General
hi Normal        ctermfg=232    guifg=#080808  ctermbg=NONE   guibg=#d0d0d0  cterm=none       gui=none
hi Visual        ctermfg=16     guifg=#000000  ctermbg=74     guibg=#5fafdf  cterm=none       gui=none
hi VisualNOS     ctermfg=52     guifg=#5f0000  ctermbg=137    guibg=#af875f  cterm=none       gui=none
hi CursorLine    ctermfg=NONE   guifg=NONE     ctermbg=250    guibg=#bcbcbc  cterm=none       gui=none
hi Search        ctermfg=253    guifg=#dadada  ctermbg=25     guibg=#005faf  cterm=none       gui=none
hi IncSearch     ctermfg=253    guifg=#dadada  ctermbg=130    guibg=#af5f00  cterm=none       gui=none
hi MatchParen    ctermfg=NONE   guifg=NONE     ctermbg=249    guibg=#b2b2b2  cterm=none       gui=none
hi ErrorMsg      ctermfg=254    guifg=#e4e4e4  ctermbg=160    guibg=#df0000  cterm=none       gui=none
hi WarningMsg    ctermfg=196    guifg=#ff0000  ctermbg=NONE   guibg=NONE     cterm=none       gui=none
hi ModeMsg       ctermfg=16     guifg=#000000  ctermbg=NONE   guibg=NONE     cterm=none       gui=none
hi MoreMsg       ctermfg=16     guifg=#000000  ctermbg=NONE   guibg=NONE     cterm=none       gui=none
hi Question      ctermfg=52     guifg=#5f0000  ctermbg=NONE   guibg=NONE     cterm=none       gui=none
" PowerLine will handle this perfectly.
"hi StatusLineNC  ctermfg=16     guifg=#000000  ctermbg=248    guibg=#a8a8a8  cterm=none       gui=none
hi VertSplit     ctermfg=16     guifg=#000000  ctermbg=NONE   guibg=NONE     cterm=none       gui=none
hi SignColumn    ctermfg=16     guifg=#000000  ctermbg=NONE   guibg=NONE     cterm=none       gui=none
hi ColorColumn   ctermfg=NONE   guifg=NONE     ctermbg=250    guibg=#bcbcbc  cterm=none       gui=none
hi TabLine       ctermfg=16     guifg=#000000  ctermbg=248    guibg=#a8a8a8  cterm=none       gui=none
hi TabLineFill   ctermfg=16     guifg=#000000  ctermbg=248    guibg=#a8a8a8  cterm=none       gui=none
hi TabLineSel    ctermfg=16     guifg=#000000  ctermbg=248    guibg=#a8a8a8  cterm=bold       gui=bold
hi StatusLine    ctermfg=16     guifg=#000000  ctermbg=248    guibg=#a8a8a8  cterm=none       gui=none
hi WildMenu      ctermfg=254    guifg=#e4e4e4  ctermbg=236    guibg=#303030  cterm=none       gui=none
hi Folded        ctermfg=NONE   guifg=NONE     ctermbg=250    guibg=#bcbcbc  cterm=none       gui=none
hi FoldColumn    ctermfg=124    guifg=#af0000  ctermbg=250    guibg=#bcbcbc  cterm=bold       gui=bold
hi Pmenu         ctermfg=16     guifg=#000000  ctermbg=248    guibg=#a8a8a8  cterm=none       gui=none
hi PmenuSel      ctermfg=254    guifg=#e4e4e4  ctermbg=236    guibg=#303030  cterm=bold       gui=bold
hi PmenuSbar     ctermfg=NONE   guifg=NONE     ctermbg=244    guibg=#808080  cterm=none       gui=none
hi PmenuThumb    ctermfg=251    guifg=#c6c6c6  ctermbg=255    guibg=#eeeeee  cterm=none       gui=none
hi LineNr        ctermfg=250    guifg=#bcbcbc  ctermbg=NONE   guibg=NONE     cterm=italic     gui=none
hi NonText       ctermfg=238    guifg=#444444  ctermbg=250    guibg=#bcbcbc  cterm=bold       gui=bold
hi SpecialKey    ctermfg=239    guifg=#4e4e4e  ctermbg=250    guibg=#bcbcbc  cterm=bold       gui=bold
hi Title         ctermfg=254    guifg=#e4e4e4  ctermbg=167    guibg=#df5f5f  cterm=none       gui=none
hi Directory     ctermfg=24     guifg=#005f87  ctermbg=NONE   guibg=NONE     cterm=bold       gui=bold
hi DiffAdd       ctermfg=NONE   guifg=NONE     ctermbg=71     guibg=#5faf5f  cterm=none       gui=none
hi DiffDelete    ctermfg=NONE   guifg=NONE     ctermbg=102    guibg=#878787  cterm=none       gui=none
hi DiffChange    ctermfg=NONE   guifg=NONE     ctermbg=167    guibg=#df5f5f  cterm=none       gui=none
hi DiffText      ctermfg=NONE   guifg=NONE     ctermbg=180    guibg=#dfaf87  cterm=none       gui=none
hi SpellBad      ctermfg=124    guifg=#af0000  ctermbg=NONE   guibg=NONE     cterm=underline  gui=underline
hi SpellCap      ctermfg=22     guifg=#005f00  ctermbg=NONE   guibg=NONE     cterm=underline  gui=underline
hi SpellLocal    ctermfg=21     guifg=#0000ff  ctermbg=NONE   guibg=NONE     cterm=underline  gui=underline
hi SpellRare     ctermfg=92     guifg=#8700df  ctermbg=NONE   guibg=NONE     cterm=underline  gui=underline

" Syntax
hi Identifier    ctermfg=52     guifg=#5f0000  ctermbg=NONE   guibg=NONE     cterm=none       gui=none
hi Statement     ctermfg=28     guifg=#008700  ctermbg=NONE   guibg=NONE     cterm=none       gui=none
hi Type          ctermfg=25     guifg=#005faf  ctermbg=NONE   guibg=NONE     cterm=none       gui=none
hi Constant      ctermfg=160    guifg=#df0000  ctermbg=NONE   guibg=NONE     cterm=none       gui=none
hi String        ctermfg=23     guifg=#005f5f  ctermbg=NONE   guibg=NONE     cterm=none       gui=none
hi Special       ctermfg=131    guifg=#af5f5f  ctermbg=NONE   guibg=NONE     cterm=bold       gui=bold
hi PreProc       ctermfg=29     guifg=#00875f  ctermbg=NONE   guibg=NONE     cterm=bold       gui=bold
hi Comment       ctermfg=241    guifg=#606060  ctermbg=NONE   guibg=NONE     cterm=italic     gui=none
hi Todo          ctermfg=254    guifg=#e4e4e4  ctermbg=166    guibg=#df5f00  cterm=none       gui=none
hi Underlined    ctermfg=NONE   guifg=NONE     ctermbg=NONE   guibg=NONE     cterm=underline  gui=underline
hi Error         ctermfg=196    guifg=#ff0000  ctermbg=NONE   guibg=NONE     cterm=bold       gui=bold
hi cPreCondit    ctermfg=131    guifg=#af5f5f  ctermbg=NONE   guibg=NONE     cterm=bold       gui=bold
hi diffRemoved   ctermfg=131    guifg=#af5f5f  ctermbg=NONE   guibg=NONE     cterm=bold       gui=bold
hi diffAdded     ctermfg=28     guifg=#008700  ctermbg=NONE   guibg=NONE     cterm=bold       gui=bold
hi diffChanged   ctermfg=130    guifg=#af5f00  ctermbg=NONE   guibg=NONE     cterm=bold       gui=bold
hi diffFile      ctermfg=25     guifg=#005faf  ctermbg=NONE   guibg=NONE     cterm=bold       gui=bold
hi diffLine      ctermfg=25     guifg=#005faf  ctermbg=NONE   guibg=NONE     cterm=bold       gui=bold
hi diffSubname   ctermfg=29     guifg=#00875f  ctermbg=NONE   guibg=NONE     cterm=bold       gui=bold

" PowerLine will handle tabbar perfectly.
hi Tb_Changed    ctermfg=196    guifg=#ff0000  ctermbg=NONE   guibg=NONE     cterm=bold       gui=bold
hi def link Tb_VisibleChanged Tb_VisibleNormal

" taglist
hi MyTagListTagName  ctermfg=244  guifg=#808080  ctermbg=15   guibg=#ffffff  cterm=reverse    gui=reverse
hi MyTagListFileName ctermfg=244  guifg=#808080  ctermbg=NONE guibg=NONE     cterm=italic     gui=italic
hi MyTagListTitle    ctermfg=0    guifg=#000000  ctermbg=NONE guibg=NONE     cterm=bold       gui=bold
hi MyTagListTagScope ctermfg=NONE guifg=NONE     ctermbg=NONE guibg=NONE     cterm=NONE       gui=NONE

" mail
hi def link mailSubject     MatchParen
hi def link mailSignature	Comment
hi mailQuoted1		ctermfg=237
hi mailQuoted2		ctermfg=243
hi mailQuoted3		ctermfg=249

" mark
hi MarkWord1     ctermfg=Black  guifg=Black    ctermbg=228    guibg=#ffff87
hi MarkWord2     ctermfg=Black  guifg=Black    ctermbg=153    guibg=#afdfff
hi MarkWord3     ctermfg=Black  guifg=Black    ctermbg=225    guibg=#ffdfff
hi MarkWord4     ctermfg=Black  guifg=Black    ctermbg=114    guibg=#87df87
hi MarkWord5     ctermfg=Black  guifg=Black    ctermbg=116    guibg=#87dfdf
hi MarkWord6     ctermfg=Black  guifg=Black    ctermbg=249    guibg=#b2b2b2

" easymotion
hi EasyMotionTarget ctermfg=Black ctermbg=228  guifg=Black    guibg=#ffff87
hi EasyMotionShade  ctermfg=247   ctermbg=none guifg=#b2b2b2  guibg=NONE

" Tagbar
hi def link TagbarSignature  Comment

" MiniBufExpl (improved) Colors
" http://fholgado.com/minibufexpl
hi MBENormal                ctermfg=240     ctermbg=NONE    cterm=italic
hi MBEChanged               ctermfg=196     ctermbg=NONE    cterm=italic
hi MBEVisibleNormal                                         cterm=reverse
hi MBEVisibleChanged        ctermfg=196     ctermbg=NONE    cterm=bold
hi MBEVisibleActiveNormal                                   cterm=reverse,underline,bold
hi MBEVisibleActiveChanged  ctermfg=196     ctermbg=None    cterm=reverse,underline,bold
