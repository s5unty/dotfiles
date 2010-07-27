"
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

syn keyword	cTodo		contained TODO FIXME XXX NOTE
