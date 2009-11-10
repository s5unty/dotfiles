set cindent

inoremap else<SPACE> <ESC>:call Else()<CR>a
inoremap for<SPACE> <ESC>:call For()<CR>a
inoremap if<SPACE> <ESC>:call If()<CR>a
inoremap while<SPACE> <ESC>:call While()<CR>a

function! While()
    iunmap while<SPACE>
    if (getline('.') =~ '^\s*$')
        exec "normal C
                    \while () {\r}
                    \\evk=6la"
    else 
        exec "normal a
                    \while "
    endif
    inoremap while<SPACE> <ESC>:call While()<CR>a
endfunction

function! For()
    iunmap for<SPACE>
    if (getline('.') =~ '^\s*$')
        exec "normal C
                    \for () {\r\r}
                    \\evk=4la"
    else 
        exec "normal a
                    \for "
    endif
    inoremap for<SPACE> <ESC>:call For()<CR>a
endfunction

function! If()
    iunmap if<SPACE>

    if (getline('.') =~ '^\s*$')
        exec "normal C
                    \if () {\r}
                    \\evk=3la"
    elseif (getline('.') =~ '^\s*}\s*\<else\>\s*$')
        exec "normal a
                    \if () {\r}
                    \\evk=10la"
    elseif (getline('.') =~ '^\s*}\s*\<else\>.*{\s*$')
        exec "normal a
                    \if () {\r} else 
                    \\evk=10la"
    else
        exec "normal a
                    \if "
    endif

    inoremap if<SPACE> <ESC>:call If()<CR>a
endfunction

function! Else()
    iunmap else<SPACE>
    if (getline('.') =~ '^\s*}\s*$')
        exec "normal a
                    \else {\r}
                    \\eO?\eC"
    else
        exec "normal a
                    \else "
    endif
    inoremap else<SPACE> <ESC>:call Else()<CR>a
endfunction
