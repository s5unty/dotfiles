nmap <F8> :w ~/jekyll/<C-R>=strftime('%F')<CR>-<C-R>=tolower(substitute(strpart(getline(3), 7), " ", "_", "g"))<CR>.markdown
nmap <F9> :!cd ~/jekyll; git add <C-R>=strftime('%F')<CR>-<C-R>=tolower(substitute(strpart(getline(3), 7), " ", "_", "g"))<CR>.markdown; git ci -m "+ <C-R>=tolower(strpart(getline(3), 7))<CR>"; git push

nmap <F12> :!rdiscount % > %.html; x-www-browser %.html<CR>

