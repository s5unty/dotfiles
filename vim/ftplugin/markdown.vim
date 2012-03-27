nmap <F8> :w ~/hacking/jekyll/<C-R>=strftime('%F')<CR>-<C-R>=tolower(substitute(strpart(getline(3), 7), " ", "_", "g"))<CR>.mkd
nmap <F9> :!cd ~/hacking/jekyll; git add <C-R>=strftime('%F')<CR>-<C-R>=tolower(substitute(strpart(getline(3), 7), " ", "_", "g"))<CR>.mkd; git ci -m "+ <C-R>=tolower(strpart(getline(3), 7))<CR>"; git push

nmap <F12> :!rdiscount % > %.html; x-www-browser %.html<CR>

set foldmethod=indent
