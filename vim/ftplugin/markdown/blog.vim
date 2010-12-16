nmap <F8> :w ~/jekyll/<C-R>=strftime('%F')<CR>-<C-R>=substitute(strpart(getline(3), 7), " ", "_", "g")<CR>.markdown
nmap <F9> :!cd ~/jekyll; git add <C-R>=strftime('%F')<CR>-<C-R>=substitute(strpart(getline(3), 7), " ", "_", "g")<CR>.markdown; git ci -m "+ <C-R>=strpart(getline(3), 7)<CR>"; git push

nmap <F12> :!markdown_py -x toc % > /tmp/%.html; x-www-browser /tmp/%.html<CR>
