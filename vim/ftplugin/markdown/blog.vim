nmap <F8> :w ~/jekyll/<C-R>=strftime('%Y-%m-%d')<CR>-<C-R>=substitute(strpart(getline(3), 7), " ", "_", "g")<CR>.markdown<CR>:!cd ~/jekyll; git add <C-R>=strftime('%Y-%m-%d')<CR>*; git ci -m "+ <C-R>=strpart(getline(3), 7)<CR>"
nmap <S-F8> :!cd ~/jekyll; git push<CR>
nmap <F9> :!markdown_py % > /tmp/a.html; x-www-browser /tmp/a.html<CR>
