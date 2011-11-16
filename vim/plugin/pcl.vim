" Language:	PCL

" 常用关键字 {{{1

" PATCH 编号
" 通用规则
let g:pcl_patch_id = 'T.\{8\}-\d\{1,2\}'
" 具体规则，如第4回Patch有3件<Patch>
"let g:pcl_patch_id = '\(T002148QP-05\|T002149QP-02\|T002157QP-03\|T006022QP-01\)'

" PG 编号
" 通用规则
let g:pcl_pg_id = 'PG\d\{5\}'
" 具体规则，如第4回拥有8件<PG>
"let g:pcl_pg_id = '\(PG72710\|PG74640\|PG82728\|PG64632\|PG71142\|PG52309\|PG71359\|PG81671\)'

" OS 架构
let g:pcl_os_arch = '\(RHEL5 IPF\)'

" PCL 版本
let g:pcl_version = '\(4.3A00\|4.2A30\|4.3A10\)'

" 日期时间
let g:pcl_date1 = '20\d\{2\}年\d\{1,2\}月\d\{1,2\}日'
let g:pcl_date2 = '20\d\{2\}[-/\.]\?\d\{1,2\}[-/\.]\?\d\{1,2\}'

" 作者
let g:pcl_fnst = 'FNST\()\|）\)\s\?\(朱\|趙\|尤\|周\|孫\|王\|許\|劉\|丁\|鄭\)'

" 总计
let g:pcl_total = '^\s\+計\s\+[0-9.]\+\(項目\|時\|時間\|回\|日\|ページ\|step\|ノード\)\?.*'
" }}}1

" PL {{{1
let g:pcl_pl_date = '作成日'
let g:pcl_pl_author = '作成者'
let g:pcl_pl_copyright = '^[Cc]opyright'
let g:pcl_pl_module_s = '^\s*修正対象モジュール\s*\(:\|：\)\s*'
let g:pcl_pl_module_e = '^\[見積情報\]'
let g:pcl_pl_rpm_s = '^\s*\(同梱する\|に同梱されている\|同梱されている\)RPM\s*'
let g:pcl_pl_rpm_e = '^\s*\(前版パッチの\(Update\|RPMS\)ディレクトリ\|修正対象モジュール\)'
" }}}

" SD {{{1
let g:pcl_sd_date = '^\[日付\]'
let g:pcl_sd_author = '^\[著者\]'
let g:pcl_sd_filename = '^\[題名\]'
let g:pcl_sd_copyright = '^[Cc]opyright'
let g:pcl_sd_source = '\(\[\)\(RM\|CL\|DCM\|CLDB\|COMMON\|DM\|SV\|APM\|pkg\.\w+\)/.*\.\?\(c\|h\|sh\)\?'
let g:pcl_sd_appendix = '★.*$'
let g:pcl_sd_target_module_s = '^\s*-\s*\(修正\|改造\)対象モジュール'
let g:pcl_sd_target_source_s = '^\s*-\s*\(修正\|改造\)対象\(ソース\|プログラム\)'
let g:pcl_sd_target_scope_s = '^\s*-\s*\(修正\|改造\)規模'
let g:pcl_sd_target_scope_e = '^\s*-\+$'
let g:pcl_sd_security = '^\s\+/.*0\?[01234567]\{3\}'
" }}}

" MT {{{1
let g:pcl_mt_date = '作成日'
let g:pcl_mt_author = '作成者'
let g:pcl_mt_copyright = '^[Cc]opyright'
let g:pcl_mt_target = '^\s*ソース\s\+'
let g:pcl_mt_case = '項目数'
let g:pcl_mt_ok = 'OK数'
let g:pcl_mt_ng = 'NG数'
let g:pcl_mt_ng_ok = 'NG.\+OK数'
let g:pcl_mt_ret = '\(\s\+結果\s*\|結果\(:\|：\)\)'
let g:pcl_mt_list = '^\s\+[a-z._]\+\s\+\d\+\s\+\d\+\s\+\d\+\s\+\d\s*'
" }}}

" main {{{1
function! <SID>PCL()
    let filename=expand('%:t')
    if filename !~ '\(計画\|PL_\|SD_\|MT_\|T[0-9]\{6\}\).*\.txt'
        return
    endif

    " Keyword
    exec 'syn match pclDate ~'.g:pcl_date1.'~'
    exec 'syn match pclDate ~'.g:pcl_date2.'~'
    exec 'syn match pclFNST ~'.g:pcl_fnst.'~'
    exec 'syn match pclPatchId ~'.g:pcl_patch_id.'~'
    exec 'syn match pclPGId ~'.g:pcl_pg_id.'~'
    exec 'syn match pclOSArch ~'.g:pcl_os_arch.'~'
    exec 'syn match pclVersion ~'.g:pcl_version.'~'
    exec 'syn match pclTotal ~'.g:pcl_total.'~'


    " Match
    if filename =~ 'PL_.*\.txt'
        call <SID>PL_Syntax()
    endif

    if filename =~ 'SD_.*\.txt'
        call <SID>SD_Syntax()
    endif

    if filename =~ 'MT_.*\.txt'
        call <SID>MT_Syntax()
    endif
endfunction

function! <SID>PL_Syntax()
    exec 'syn match pclPLDate ~'.g:pcl_pl_date.'~'
    exec 'syn match pclPLAuthor ~'.g:pcl_pl_author.'~'
    exec 'syn match pclPLCopyright ~'.g:pcl_pl_copyright.'~'
    exec 'syn region pclPLModule start=~'.g:pcl_pl_module_s.'~ms=e+1 end=~'.g:pcl_pl_module_e.'~me=s-1'
    exec 'syn region pclPLRpm start=~'.g:pcl_pl_rpm_s.'~ms=e+1 end=~'.g:pcl_pl_rpm_e.'~me=s-1'
endfunction

function! <SID>SD_Syntax()
    exec 'syn match pclSDDate ~'.g:pcl_sd_date.'~'
    exec 'syn match pclSDAuthor ~'.g:pcl_sd_author.'~'
    exec 'syn match pclSDFilename ~'.g:pcl_sd_filename.'~'
    exec 'syn match pclSDCopyright ~'.g:pcl_sd_copyright.'~'
    exec 'syn match pclSDSource ~'.g:pcl_sd_source.'~'
    exec 'syn match pclSDAppendix ~'.g:pcl_sd_appendix.'~'

    exec 'syn region pclSDTargetModule start=~'.g:pcl_sd_target_module_s.'~ms=e+1 end=~'.g:pcl_sd_target_source_s.'~me=s-1'
    exec 'syn region pclSDTargetSource start=~'.g:pcl_sd_target_source_s.'~ms=e+1 end=~'.g:pcl_sd_target_scope_s.'~me=s-1'
    exec 'syn region pclSDTargetScope start=~'.g:pcl_sd_target_scope_s.'~ms=e+1 end=~'.g:pcl_sd_target_scope_e.'~me=s-1'
    exec 'syn match pclSDTargetSecurity ~'.g:pcl_sd_security.'~'
endfunction

function! <SID>MT_Syntax()
    exec 'syn match pclMTDate ~'.g:pcl_mt_date.'~'
    exec 'syn match pclMTAuthor ~'.g:pcl_mt_author.'~'
    exec 'syn match pclMTCopyright ~'.g:pcl_mt_copyright.'~'

    exec 'syn match pclMTTarget ~'.g:pcl_mt_target.'~'
    exec 'syn match pclMTCase ~'.g:pcl_mt_case.'~'
    exec 'syn match pclMTOk ~'.g:pcl_mt_ok.'~'
    exec 'syn match pclMTNg ~'.g:pcl_mt_ng.'~'
    exec 'syn match pclMTNgOk ~'.g:pcl_mt_ng_ok.'~'
    exec 'syn match pclMTRet ~'.g:pcl_mt_ret.'~'
    exec 'syn match pclMTList ~'.g:pcl_mt_list.'~'

endfunction

autocmd BufEnter,WinEnter *.txt
    \ call <SID>PCL()

" }}}

hi def link pclTest             Error

hi def link pclFNST             Keyword
hi def link pclDate             Keyword
hi def link pclPatchId          String
hi def link pclPGId             String
hi def link pclOSArch           String
hi def link pclVersion          String
hi def link pclComponent        String
hi def link pclTotal            String

hi def link pclPLDate           Todo
hi def link pclPLAuthor         Todo
hi def link pclPLCopyright      Todo
hi def link pclPLModule         Tag
hi def link pclPLRpm            Tag

hi def link pclSDDate           Todo
hi def link pclSDAuthor         Todo
hi def link pclSDFilename       Todo
hi def link pclSDCopyright      Todo
hi def link pclSDSource         Tag
hi def link pclSDAppendix       String
hi def link pclSDTargetModule   Tag
hi def link pclSDTargetSource   Tag
hi def link pclSDTargetScope    Tag
hi def link pclSDTargetSecurity Tag

hi def link pclMTDate           Todo
hi def link pclMTAuthor         Todo
hi def link pclMTCopyright      Todo
hi def link pclMTTarget         Type
hi def link pclMTCase           Type
hi def link pclMTOk             Type
hi def link pclMTNg             Type
hi def link pclMTNgOk           Type
hi def link pclMTRet            Type
hi def link pclMTList           Tag

