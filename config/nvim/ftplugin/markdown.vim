nmap <buffer> <C-F10> :w ~/maildir/notebook/cur/<C-R>=strftime('%F')<CR>-<C-R>=tolower(substitute(strpart(getline(1), 9), " ", "_", "g"))<CR>.mkd

nmap <buffer> <C-F12> :!pandoc "%" -o "/tmp/%.html"; x-www-browser "/tmp/%.html"<CR>

function Title(line, column)
    let ret = tolower(strpart(getline(a:line), a:column))
    let ret = substitute(ret, '"', '', "g")
    let ret = substitute(ret, "'", "", "g")
    let ret = substitute(ret, ' ', "-", "g")
    return ret
endfunction

function Filename()
    let date = strftime('%F')
    let title = Title(3, 7)
    let ret = date . "-" . title . ".md"
    echo ret
    return ret
endfunction

nmap <buffer> <F8> :w ~/du1ab.org/content/posts/<C-R>=Filename()<CR>
nmap <buffer> <F9> :!cd ~/du1ab.org/content/posts/; git add '<C-R>=Filename()<CR>'; git ci -m '$(date +\%s)'; git push

set foldmethod=indent
