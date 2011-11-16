" Language:	PCL

let g:pcl_date = '\d\{4\}年\d\{1,2\}月\d\{1,2\}日'
let g:pcl_fnst = 'FNST)\s\?\(朱\|趙\|尤\|周\|孫\|王\|許\|劉\|丁\|鄭\)'
let g:pcl_sd_date = ''
let g:pcl_sd_author = ''

function! <SID>PCL()
    let filename=expand('%:t')
    if filename !~ '\(PL\|SD\|MT\)_.*\.txt'
        return
    endif

    if filename =~ 'SD_.*\.txt'
        call <SID>SD_Syntax()
    endif
endfunction

function! <SID>SD_Syntax()
    execute 'syntax match PclSDDate /'.g:pcl_sd_date.'/'
    execute 'syntax match PclSDAuthor /'.g:pcl_sd_author.'/'

    hi def link PclSDDate     Error
    hi def link PclSDAuthor     Error
endfunction

autocmd BufEnter,WinEnter *.txt
    \ call <SID>PCL()

