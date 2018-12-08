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
    let ret = date . "-" . title . ".adoc"
    echo ret
    return ret
endfunction

nmap <buffer> <F8> :w ~/du1abadd/content/post/<C-R>=Filename()<CR>
nmap <buffer> <F9> :!cd ~/du1abadd/content/post; git add '<C-R>=Filename()<CR>'; git ci -m '+ <C-R>=Title(3, 8)<CR>'; git push
nmap <buffer> <F12> :!asciidoctor -o "/tmp/.adoc.html" %; x-www-browser "/tmp/.adoc.html"<CR>

set foldmethod=indent

