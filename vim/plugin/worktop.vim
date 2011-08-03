function! <SID>foo()
    let fname = shellescape(expand("%"))
    let line1 = shellescape(line("'<"))
    let line2 = shellescape(line("'>"))
    let cname = "/sun/worktop/crm/read_source_code.log.".strftime("%Y%m%d")

    let cmd = "echo ".fname.":".line1."~".line2.">>".cname

    call system("date +'# %F %R' >>".cname)
    call system(cmd)
endfunction
vmap <silent> <unique> <F9> <ESC>:call <SID>foo()<CR>
