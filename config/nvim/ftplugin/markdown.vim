nmap <buffer> <C-F8> :w ~/desktop/Dropbox/trunksync/notes/<C-R>=strftime('%Y_%m_%d_%H:%M')<CR>.markdown

nmap <buffer> <C-F8> :w ~/hacking/jekyll/<C-R>=strftime('%F')<CR>-<C-R>=tolower(substitute(strpart(getline(3), 7), " ", "_", "g"))<CR>.mkd
nmap <buffer> <C-F9> :!cd ~/hacking/jekyll; git add '<C-R>=strftime('%F')<CR>-<C-R>=tolower(substitute(strpart(getline(3), 7), " ", "_", "g"))<CR>.mkd'; git ci -m '+ <C-R>=tolower(strpart(getline(3), 7))<CR>'; git push
nmap <buffer> <C-F10> :w ~/maildir/notebook/cur/<C-R>=strftime('%F')<CR>-<C-R>=tolower(substitute(strpart(getline(1), 9), " ", "_", "g"))<CR>.mkd

nmap <buffer> <C-F12> :!pandoc "%" -o "/tmp/%.html"; x-www-browser "/tmp/%.html"<CR>

set foldmethod=indent
