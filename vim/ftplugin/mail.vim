" Checking attachments in edited emails for use in Mutt: warns user when
" exiting
" by Hugo Haas <hugo@larve.net> - 20 June 2004
" based on an idea by The Doctor What explained at
" <mid:caq406$rq4$1@FreeBSD.csie.NCTU.edu.tw>
autocmd BufUnload mutt* call CheckAttachments()
function! CheckAttachments()
  let l:english = 'attach\(ing\|ed\|ment\)\?'
  let l:chinese = '附件'
  let l:ic = &ignorecase
  if (l:ic == 0)
    set ignorecase
  endif
  if (search('^\([^>|].*\)\?\(re-\?\)\?\(' . l:english . '\|' . l:chinese . '\)', "w") != 0)
    let l:temp = inputdialog("Do not forget to attach a file [Hit return] ")
  endif
  if (l:ic == 0)
    set noignorecase
  endif
  echo
endfunction

set textwidth=78
set formatoptions+=mM
