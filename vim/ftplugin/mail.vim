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

" 保存之前，在中文和英文的交接处，自动添加空格
autocmd BufWrite mutt* call BetweenEnglishChinese()
function! BetweenEnglishChinese()
    " 到邮件签名为止，剩余部分不用管
    let tailine = search('^-- $', 'n')
    for linenum in range(1, tailine)
        " 只管撰写的正文，忽略引用
        if getline(linenum) =~ "^[ ]*[>|].*"
            continue
        endif

        let oldline = getline(linenum)
        let newline = substitute(oldline, '\([\u4e00-\u9fa5]\)\(\w\)', '\1 \2', 'g')
        let newline = substitute(newline, '\(\w\)\([\u4e00-\u9fa5]\)', '\1 \2', 'g')
        call setline(linenum, newline)
    endfor
endfunction

set textwidth=68
set colorcolumn=80
set formatoptions+=12mnM
