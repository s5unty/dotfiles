set cindent

inoremap #define<SPACE> <ESC>:call Define()<CR>a
inoremap else<SPACE> <ESC>:call Else()<CR>a
inoremap for<SPACE> <ESC>:call For()<CR>a
inoremap if<SPACE> <ESC>:call If()<CR>a
inoremap while<SPACE> <ESC>:call While()<CR>a
inoremap switch<SPACE> <ESC>:call Switch()<CR>a
inoremap struct<SPACE> <ESC>:call Struct()<CR>a
inoremap class<SPACE> <ESC>:call Class()<CR>a

function! Class()
    iunmap class<SPACE>
    if (getline('.') =~ '^\s*$')
        exec "normal a
                    \class {\rpublic:\rprivate:\r};
                    \\ekVk<k$1ha"
    else 
        exec "normal a
                    \class "
    endif
    inoremap class<SPACE> <ESC>:call Class()<CR>a
endfunction

function! Struct()
    iunmap struct<SPACE>
    if (getline('.') =~ '^\s*$')
        exec "normal a
                    \struct {\r};
                    \\ek$1ha"
    else 
        exec "normal a
                    \struct "
    endif
    inoremap struct<SPACE> <ESC>:call Struct()<CR>a
endfunction

function! Define()
    iunmap #define<SPACE>
    if (getline('.') =~ '^\s*$')
        exec "normal a
                    \#define \r#endif //
                    \\evk=$a"
    else 
        exec "normal a
                    \#define "
    endif
    inoremap #define<SPACE> <ESC>:call Define()<CR>a
endfunction

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

function! Switch()
    iunmap switch<SPACE>
    if (getline('.') =~ '^\s*$')
        exec "normal C
                    \switch () {\r}
                    \\evk=7la"
    else 
        exec "normal a
                    \while "
    endif
    inoremap switch<SPACE> <ESC>:call Switch()<CR>a
endfunction

function! For()
    iunmap for<SPACE>
    if (getline('.') =~ '^\s*$')
        exec "normal C
                    \for () {\r}
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

