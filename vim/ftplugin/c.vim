" fold {{{1
function! FoldBrace()
  if getline(v:lnum+1)[0] == '{'
    return 1
  endif
  if getline(v:lnum) =~ '{'
    return 1
  endif
  if getline(v:lnum)[0] =~ '}'
    return '<1'
  endif
  return -1
endfunction
set foldexpr=FoldBrace()
set foldmethod=expr
set nofoldenable

" syntax {{{1
syn keyword	cTodo		contained TODO FIXME XXX NOTE
let c_space_errors=1
" If you notice highlighting errors while scrolling backwards, which are fixed
" when redrawing with CTRL-L, try setting the "c_minlines" internal variable
" to a larger number:
let c_minlines = 500

" key map {{{1
nmap <silent> <F8> :make!<CR>:call G_QFixToggle(1)<CR>
imap <silent> <F8> <ESC>:make!<CR>:call G_QFixToggle(1)<CR>

