nmap <buffer> <F8> :w ~/hacking/jekyll/<C-R>=strftime('%F')<CR>-<C-R>=tolower(substitute(strpart(getline(3), 7), " ", "_", "g"))<CR>.asciidoc
nmap <buffer> <F9> :!cd ~/hacking/jekyll; git add '<C-R>=strftime('%F')<CR>-<C-R>=tolower(substitute(strpart(getline(3), 7), " ", "_", "g"))<CR>.asciidoc'; git ci -m '+ <C-R>=tolower(strpart(getline(3), 7))<CR>'; git push
nmap <buffer> <F10> :w ~/maildir/notebook/cur/<C-R>=strftime('%F')<CR>-<C-R>=tolower(substitute(strpart(getline(1), 9), " ", "_", "g"))<CR>.asciidoc

nmap <buffer> <F12> :!asciidoc -o "/tmp/.asciidoc.html" %; x-www-browser "/tmp/.asciidoc.html"<CR>

set foldmethod=indent

