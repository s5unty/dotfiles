" Checking attachments in edited emails for use in Mutt: warns user when
" exiting
" by Hugo Haas <hugo@larve.net> - 20 June 2004
" based on an idea by The Doctor What explained at
" <mid:caq406$rq4$1@FreeBSD.csie.NCTU.edu.tw>
autocmd BufUnload mutt* call CheckAttachments()
function! CheckAttachments()
  let l:en = 'attach\(ing\|ed\|ment\)\?'
  let l:zh = '\(附件\|截图\|查收\)'
  let l:ja = '添付'
  let l:ic = &ignorecase
  if (l:ic == 0)
    set ignorecase
  endif
  if (search('^\([^>|].*\)\?\(re-\?\)\?\(' . l:en . '\|' . l:zh . '\|' . l:ja. '\)', "w") != 0)
    let l:temp = inputdialog("★☆★☆ Do not forget to attach the file(s) ☆★☆★ [Hit return]")
  endif
  if (l:ic == 0)
    set noignorecase
  endif
  echo
endfunction

set textwidth=68
set colorcolumn=80
set formatoptions+=12mnM
