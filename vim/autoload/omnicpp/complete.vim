" Description:  Omni completion script for resolve namespace
" Maintainer:   fanhe <fanhed@163.com>
" Create:       2011 May 14
" License:      GPLv2

"临时启用选项函数 {{{2
function! s:SetOpts()
    let s:bak_cot = &completeopt

    if g:VLOmniCpp_ItemSelectionMode == 0 " 不选择
        set completeopt-=menu,longest
        set completeopt+=menuone
    elseif g:VLOmniCpp_ItemSelectionMode == 1 " 选择并插入文本
        set completeopt-=menuone,longest
        set completeopt+=menu
    elseif g:VLOmniCpp_ItemSelectionMode == 2 " 选择但不插入文本
        set completeopt-=menu,longest
        set completeopt+=menuone
    else
        set completeopt-=menu
        set completeopt+=menuone,longest
    endif

    return ''
endfunction
function! s:RestoreOpts()
    if exists('s:bak_cot')
        let &completeopt = s:bak_cot
        unlet s:bak_cot
    else
        return ""
    endif

    let sRet = ""

    if pumvisible()
        if g:VLOmniCpp_ItemSelectionMode == 0 " 不选择
            let sRet = "\<C-p>"
        elseif g:VLOmniCpp_ItemSelectionMode == 1 " 选择并插入文本
            let sRet = ""
        elseif g:VLOmniCpp_ItemSelectionMode == 2 " 选择但不插入文本
            let sRet = "\<C-p>\<Down>"
        else
            let sRet = "\<Down>"
        endif
    endif

    return sRet
endfunction
function! s:CheckIfSetOpts()
    let sLine = getline('.')
    let nCol = col('.') - 1
    "若是成员补全，添加 longest
    if sLine[nCol-2:] =~ '->' || sLine[nCol-1:] =~ '\.' 
                \|| sLine[nCol-2:] =~ '::'
        call s:SetOpts()
    endif

    return ''
endfunction
"}}}
function! s:CanComplete() "{{{2
    if (getline('.') =~ '#\s*include')
        " 写头文件，忽略
        return 0
    else
        " 检测光标所在的位置，如果在注释、双引号、浮点数时，忽略
        let nLine = line('.')
        let nCol = col('.') - 1 " 是前一列 eg. ->|
        if nCol < 1
            " TODO: 支持续行的补全
            return 0
        endif
        if g:VLOmniCpp_EnableSyntaxTest
            for nID in synstack(nLine, nCol)
                if synIDattr(nID, 'name') 
                            \=~? 'comment\|string\|number\|float\|character'
                    return 0
                endif
            endfor
        else
            " TODO
        endif

        return 1
    endif
endfunction
"}}}
function! s:LaunchOmniCppCompletion() "{{{2
    if s:CanComplete()
        return "\<C-x>\<C-o>"
    else
        return ''
    endif
endfunction
"}}}
function! s:CompleteByChar(sChar) "{{{2
    if a:sChar ==# '.'
        return a:sChar . s:LaunchOmniCppCompletion()
    elseif a:sChar ==# '>'
        if getline('.')[col('.') - 2] != '-'
            return a:sChar
        else
            return a:sChar . s:LaunchOmniCppCompletion()
        endif
    elseif a:sChar ==# ':'
        if getline('.')[col('.') - 2] != ':'
            return a:sChar
        else
            return a:sChar . s:LaunchOmniCppCompletion()
        endif
    endif
endfunction
"}}}
function! omnicpp#complete#Init() "{{{2
    if !exists('g:VLWorkspaceHasStarted') || !g:VLWorkspaceHasStarted
        " 仅支持在 VimLite 中使用
        return ''
    endif

    " 初始化数据库
    call VimTagsManagerInit()

    " 初始化函数 Calltips 服务
    call g:InitVLCalltips()
    exec 'inoremap <silent> <buffer> ' . g:VLCalltips_DispCalltipsKey 
                \. ' <C-r>=<SID>RequestCalltips()<CR>'

    " 初始化设置
    call omnicpp#settings#Init()

    "setlocal completefunc=
    setlocal omnifunc=omnicpp#complete#Complete

    " TODO: 不应该使用全局变量
    let g:dOCppNSAlias = {} " 名空间别名 {'abc': 'std'}
    let g:dOCppUsing = {} " using. eg. {'cout': 'std::out', 'cin': 'std::cin'}

    " 硬替换类型, 补全前修改为合适的值
    if !exists('g:dOCppTypes')
        let g:dOCppTypes = {}
        let g:dOCppTypes = {
                    \'std::vector::reference': '_Tp', 
                    \'std::vector::const_reference': '_Tp', 
                    \'std::vector::iterator': '_Tp', 
                    \'std::vector::const_iterator': '_Tp', 
                    \'std::queue::reference': '_Tp', 
                    \'std::queue::const_reference': '_Tp', 
                    \'std::queue::iterator': '_Tp', 
                    \'std::queue::const_iterator': '_Tp', 
                    \'std::set::const_iterator': '_Key', 
                    \'std::set::iterator': '_Key', 
                    \'std::deque::reference': '_Tp', 
                    \'std::deque::const_reference': '_Tp', 
                    \'std::deque::iterator': '_Tp', 
                    \'std::deque::const_iterator': '_Tp', 
                    \'std::map::iterator': 'pair<_Key, _Tp>', 
                    \'std::map::const_iterator': 'pair<_Key,_Tp>', 
                    \'std::multimap::iterator': 'pair<_Key,_Tp>', 
                    \'std::multimap::const_iterator': 'pair<_Key,_Tp>'
                    \}
    endif

    if g:VLOmniCpp_MayCompleteDot
        inoremap <silent> <buffer> . 
                    \<C-r>=<SID>SetOpts()<CR>
                    \<C-r>=<SID>CompleteByChar('.')<CR>
                    \<C-r>=<SID>RestoreOpts()<CR>
    endif

    if g:VLOmniCpp_MayCompleteArrow
        inoremap <silent> <buffer> > 
                    \<C-r>=<SID>SetOpts()<CR>
                    \<C-r>=<SID>CompleteByChar('>')<CR>
                    \<C-r>=<SID>RestoreOpts()<CR>
    endif

    if g:VLOmniCpp_MayCompleteColon
        inoremap <silent> <buffer> : 
                    \<C-r>=<SID>SetOpts()<CR>
                    \<C-r>=<SID>CompleteByChar(':')<CR>
                    \<C-r>=<SID>RestoreOpts()<CR>
    endif

    inoremap <script> <Plug>SmartComplete 
                \<C-r>=<SID>CheckIfSetOpts()<CR>
                \<C-r>=<SID>LaunchOmniCppCompletion()<CR>
                \<C-r>=<SID>RestoreOpts()<CR>

    "显示函数 calltips 的快捷键
    if g:VLOmniCpp_MapReturnToDispCalltips
        inoremap <silent> <expr> <buffer> <CR> pumvisible() ? 
                    \"\<C-y>\<C-r>=<SID>RequestCalltips(1)\<Cr>" : 
                    \"\<CR>"
    endif

    if g:VLOmniCpp_ItemSelectionMode > 4
        imap <silent> <buffer> <C-n> <Plug>SmartComplete
    else
        "inoremap <silent> <buffer> <C-n> 
                    "\<C-r>=<SID>SetOpts()<CR>
                    "\<C-r>=<SID>LaunchOmniCppCompletion()<CR>
                    "\<C-r>=<SID>RestoreOpts()<CR>
    endif
endfunction
"}}}
function! s:RequestCalltips(...) " 可选参数标识是否刚在补全后发出请求 {{{2
    if a:0 > 0 && a:1 " 从全能补全菜单选择条目后，使用上次的输出
        let sLine = getline('.')
        let nCol = col('.')
        if sLine[nCol-3:] =~ '^()'
            normal! h
            let sFuncName = matchstr(sLine[: nCol-4], '\w\+$')

            let lCalltips = s:GetCalltips(s:lTags, sFuncName)
            call g:DisplayVLCalltips(lCalltips, 0)
        endif
    else " 普通情况，请求 calltips
        " 确定函数括号开始的位置
        let lOrigCursor = getpos('.')
        " 返回 1 则跳过此匹配. 手册有误, 说返回 0 就跳过!
        if g:VLOmniCpp_EnableSyntaxTest
            " 跳过字符串中和注释中的匹配
            let sSkipExpr = 'synIDattr(synID(line("."), col("."), 0), "name") '
                        \. '=~? "character\\|string\\|comment"'
        else
            " 空则不跳过任何匹配
            let sSkipExpr = ''
        endif
        let lStartPos = searchpairpos('(', '', ')', 'nWb', sSkipExpr)
        "考虑刚好在括号内，加 'c' 参数
        let lEndPos = searchpairpos('(', '', ')', 'nWc', sSkipExpr)
        let lCurPos = lOrigCursor[1:2]

        "不在括号内
        if lStartPos ==# [0, 0]
            return ''
        endif

        "获取函数名称和名称开始的列，只能处理 '(' "与函数名称同行的情况，
        "允许之间有空格
        let sStartLine = getline(lStartPos[0])
        let sFuncName = matchstr(sStartLine[: lStartPos[1]-1], '\w\+\ze\s*($')
        let nFuncStartIdx = match(sStartLine[: lStartPos[1]-1], '\w\+\ze\s*($')

        let lCalltips = []
        if sFuncName != ''
            "找到了函数名，开始全能补全
            call setpos('.', [0, lStartPos[0], lStartPos[1], 0])
            let nStartCol = omnicpp#complete#Complete(1, '')
            call setpos('.', [0, lStartPos[0], nFuncStartIdx+1, 0])
            let lTags = omnicpp#complete#Complete(0, sFuncName)
            let lCalltips = s:GetCalltips(lTags, sFuncName)
        endif

        call setpos('.', lOrigCursor)
        call g:DisplayVLCalltips(lCalltips, 0)
    endif

    return ''
endfunction
"}}}
function! s:GetCalltips(lTags, sFuncName) "{{{2
    let lTags = a:lTags
    let sFuncName = a:sFuncName

    let lCalltips = []
    for dTag in lTags
        if dTag.name ==# sFuncName 
            " 如果声明和定义分开, 只取声明的 tag
            " ctags 中, 解析类方法定义的时候是没有访问控制信息的
            " 1. 原型
            " 2. C 中的函数(kind == 'f', !has_key(dTag, 'class'))
            " 3. C++ 中的内联成员函数
            if dTag.kind ==# 'p' 
                        \|| (dTag.kind ==# 'f' && !has_key(dTag, 'class'))
                        \|| (dTag.kind ==# 'f' && has_key(dTag, 'class') 
                        \    && has_key(dTag, 'access'))
                let sName = dTag.path
                " 首先尝试在模式中查找限定词, 
                " 若查找失败才用 tag 中的 qualifiers 域, 因为这个域的解析不完善
                " FIXME: python 的字典转为 vim 字典时, \t 全部丢失
                let sQualifiers = substitute(dTag.cmd[2:-3], '\\t', ' ', 'g')
                let sQualifiers = matchstr(sQualifiers, 
                            \'\C\s*\zs[^;]\{-}\ze' . sFuncName)
                if sQualifiers ==# ''
                    let sQualifiers = dTag.qualifiers . ' '
                endif
                if sQualifiers =~# '::\s*$'
                    let sName = sFuncName
                endif
                call add(lCalltips, printf("%s%s%s", sQualifiers, 
                            \              sName, dTag.signature))
            endif
        endif
    endfor

    return lCalltips
endfunction
"}}}
let s:CompletionType_NormalCompl = 0    " 作用域内符号补全
let s:CompletionType_MemberCompl = 1    " 作用域内变量成员补全 ('::', '->', '.')
let s:nCompletionType = s:CompletionType_NormalCompl " 用于标识补全类型
let s:bDoNotComplete = 0 " 用于 omnifunc 第一阶段与第二阶段通讯, 指示禁止补全
let s:bIsScopeOperation = 0 " 用于区分是否作用域操作符的成员补全
let s:lCurentStatement = [] " 当前语句的 token 列表
" omnifunc
function! omnicpp#complete#Complete(findstart, base) "{{{2
    if a:findstart
        let s:nCompletionType = s:CompletionType_NormalCompl
        let s:bDoNotComplete = 0
        let s:bIsScopeOperation = 0
        "call g:Timer.Start() "计时用

        let nStartIdx = col('.') - 1
        let sLine = getline('.')[: nStartIdx-1]

        " 跳过光标在注释和字符串中的补全请求
        if omnicpp#utils#IsCursorInCommentOrString()
            " BUG: 返回 -1 仍然进入下一阶段
            let s:bDoNotComplete = 1
            return -1
        endif

if 1
        " 基于 tokens 的预分析
        let lTokens = omnicpp#utils#TokenizeStatementBeforeCursor(1)
        let s:lTokens = lTokens
        let b:lTokens = lTokens
        if empty(lTokens)
            " (1) 无预输入的作用域内符号补全不支持, 因为可能太多符号
            let s:bDoNotComplete = 1
            return -1
        endif

        if lTokens[-1].kind == 'cppWord'
            " 肯定是有预输入的补全, 至于是不是成员补全需要进一步分析
            let s:lTokens = lTokens[:-2]

            if  sLine[-1:-1] =~# '\s' || sLine[-1:-1] ==# ''
                " 有预输入, 但是光标不邻接单词, 不能补全
                let s:bDoNotComplete = 1
                return -1
            endif

            if len(lTokens) >= 2 && lTokens[-2].value =~# '\.\|->\|::'
                if lTokens[-1].value ==# '::'
                    let s:bIsScopeOperation = 1
                else
                    let s:bIsScopeOperation = 0
                endif
                " (3) 有预输入的成员补全
                let s:nCompletionType = s:CompletionType_MemberCompl
            else
                " (2) 有预输入的作用域内符号补全
                let s:nCompletionType = s:CompletionType_NormalCompl
            endif

            let nRet = searchpos('\C' . lTokens[-1].value, 'Wbn')[1]
            let b:fs = nRet
            " BUG: 居然要减一才工作
            return nRet - 1
        elseif lTokens[-1].value =~# '\.\|->\|::'
            " (4) 无预输入的成员补全
            let s:nCompletionType = s:CompletionType_MemberCompl
            if lTokens[-1].value ==# '::'
                let s:bIsScopeOperation = 1
            else
                let s:bIsScopeOperation = 0
            endif

            let b:fs = col('.')
            return col('.')
        else
            let s:bDoNotComplete = 1
            return -1
        endif
else
        " 基于字符的预分析
        if sLine[nStartIdx - 1] =~ '\s' || sLine == ''
            " 光标前的字符为空字符, 要么不能补全, 要么是无预输入的成员补全
            let s:nCompletionType = s:CompletionType_MemberCompl

            "跳过空格， . -> :: 之间是允许空格的...
            let nStartIdx = match(sLine[:nStartIdx-1], '\S\s*$')

            if sLine[:nStartIdx] =~# '->$\|::$\|\.$'
                if sLine[nStartIdx] ==# ':'
                    let s:bIsScopeOperation = 1
                else
                    let s:bIsScopeOperation = 0
                endif
                " 成员补全. eg. std::, MyClass->
                let nCol = nStartIdx + 1
                return col('.')
            else
                " 没有成员补全操作符, 补全失败
                let s:bDoNotComplete = 1
                return -1
            endif
        else
            " 光标前的字符为非空字符, 无论如何都会请求补全
            " 两种补全都有可能. eg. MyClass->|, MyClass.m_|
            if sLine[: nStartIdx-1] =~# '->$\|::$\|\.$'
                if sLine[nStartIdx-1] ==# ':'
                    let s:bIsScopeOperation = 1
                else
                    let s:bIsScopeOperation = 0
                endif
                " 无预输入的成员补全. eg. std::, MyClass->
                let nCol = nStartIdx + 1
                let s:nCompletionType = s:CompletionType_MemberCompl
                return col('.')
            else
                " 有预输入的作用域符号或成员补全
                if sLine[: nStartIdx-1] =~# '\%(->\|::\|\.\)\s*\w\+$'
                    if sLine[: nStartIdx-1] =~# '::\s*\w\+$'
                        let s:bIsScopeOperation = 1
                    else
                        let s:bIsScopeOperation = 0
                    endif
                    let s:nCompletionType = s:CompletionType_MemberCompl
                endif

                " NOTE: 为什么这里返回的列数比实际的小 1 还能正常工作?
                return match(sLine, '\<\w\+$')
            endif
        endif
endif
    endif

    let lResult = []

    if s:bDoNotComplete
        let s:bDoNotComplete = 0
        return lResult
    endif

    let sBase = a:base
    let b:base = a:base
    let b:findstart = col('.')

    let lScopeStack = omnicpp#scopes#GetScopeStack()
    " 设置全局变量, 用于 GetStopPosForLocalDeclSearch() 里面使用...
    let g:lOCppScopeStack = lScopeStack 
    "let lSimpleSS = omnicpp#complete#SimplifyScopeStack(lScopeStack)
    let lTagScopes = []
    let lTags = []

    if s:nCompletionType == s:CompletionType_NormalCompl
        " (1) 作用域内非成员补全模式

        let dScopeInfo = omnicpp#resolvers#ResolveScopeStack(lScopeStack)
        let lTagScopes = dScopeInfo.container + dScopeInfo.global 
                    \+ dScopeInfo.function
    else
        " (2) 作用域内成员补全模式

        if exists('s:lTokens')
            let dOmniInfo = omnicpp#resolvers#GetOmniInfo(s:lTokens)
        else
            let dOmniInfo = omnicpp#resolvers#GetOmniInfo()
        endif
        if empty(dOmniInfo.omniss) && dOmniInfo.precast ==# '<global>'
                    \&& sBase ==# ''
            " 禁用全局全符号补全, 因为会卡
            return []
        endif

        let lTagScopes = omnicpp#resolvers#ResolveOmniInfo(
                    \lScopeStack, dOmniInfo)
        "let b:dOmniInfo = dOmniInfo
    endif

    if !empty(lTagScopes)
        "let lTags = g:GetTagsByScopesAndName(lTagScopes, sBase)
        let lTags = g:GetOrderedTagsByScopesAndName(lTagScopes, sBase)
        if !s:bIsScopeOperation 
                    \&& s:nCompletionType == s:CompletionType_MemberCompl
            " 过滤类型定义, 结构, 类
            call map(lTags, 's:ExtendTagToPopupMenuItem(v:val, "t", "s", "c")')
        else
            call map(lTags, 's:ExtendTagToPopupMenuItem(v:val)')
        endif
    endif

    " 添加 using 声明和名空间别名的名字
    if s:nCompletionType == s:CompletionType_NormalCompl
        for sName in keys(g:dOCppUsing)
            if sName =~ '^' . sBase
                let dItem = {}
                let dItem.word = sName
                let dItem.abbr = sName
                let dItem.menu = '  <using>'
                let dItem.kind = 'x'
                let dItem.icase = &ic
                let dItem.dup = 0
                call add(lTags, dItem)
            endif
        endfor

        for sName in keys(g:dOCppNSAlias)
            if sName =~ '^' . sBase
                let dItem = {}
                let dItem.word = sName
                let dItem.abbr = sName
                let dItem.menu = '  <nsalias>'
                let dItem.kind = 'n'
                let dItem.icase = &ic
                let dItem.dup = 0
                call add(lTags, dItem)
            endif
        endfor
    endif

    let lResult = lTags
    let s:lTags = lTags

    " 调试用
    "let b:lTagScopes = lTagScopes
    "let b:lTags = lTags

    unlet g:lOCppScopeStack
    "call g:Timer.EndEchoMes() " 计时用

    return lResult
endfunc
"}}}
" 简化 ScopeStack, scope.kind 为 'other' 的合并进前一个 scope
" 返回的是副本
function! omnicpp#complete#SimplifyScopeStack(lScopeStack) "{{{2
    let lResult = []
    for dScope in a:lScopeStack
        if dScope.kind == 'other'
            let dPrevScope = lResult[-1]
            let dPrevScope.namespaces += dScope.namespaces
            let dPrevScope.includes += dScope.namespaces
        else
            call add(lResult, copy(dScope))
        endif
    endfor

    return lResult
endfunc
"}}}
" Extend a tag entry to a popup entry
" 从 tag 字典生成补全字典(用于补全条目), 并把结果存在 tag 字典中(key 不重复?)
" 可选参数控制需要过滤的类型
function! s:ExtendTagToPopupMenuItem(dTag, ...) "{{{2
    let dTag = a:dTag
    let lFilterKinds = a:000

    " 过滤特定的类型
    if index(lFilterKinds, dTag.kind) >= 0
        return dTag
    endif

    if dTag.kind == 'f' && has_key(dTag, 'class') && !has_key(dTag, 'access')
        " 如此 tag 为类的成员函数, 类型为函数, 且没有访问控制信息, 跳过
        " 防止没有访问控制信息的类成员函数条目覆盖带访问控制信息的成员函数原型的
        return dTag
    endif

    " Add the access
    let sMenu = ''
    let dAccessChar = {'public': '+','protected': '#','private': '-'}
    if 1
        if has_key(dTag, 'access') && has_key(dAccessChar, dTag.access)
            let sMenu = sMenu.dAccessChar[dTag.access]
        else
            let sMenu = sMenu." "
        endif
    endif

    " Formating optional menu string we extract the scope information
    let sName = dTag.name
    let sWord = sName
    let sAbbr = sName

    if 1
        let sMenu = sMenu . ' ' . dTag.parent
    endif

    " Formating information for the preview window
    if index(['f', 'p'], dTag.kind[0]) >= 0
        if 0 && has_key(dTag, 'signature')
            let sAbbr .= dTag.signature
        else
            let sWord .= '()'
            let sAbbr .= '()'
        endif
    endif

    let sInfo = ''

    " If a function is a ctor we add a new key in the tag
    " 构造函数处理, 以及友元处理
    "if index(['f', 'p'], dTag.kind[0]) >= 0
        "if match(sName, '^\~') < 0 && a:szTypeName =~ '\C\<'.sName.'$'
            " It's a ctor
            "let dTag['ctor'] = 1
        "elseif has_key(dTag, 'access') && dTag.access == 'friend'
            " Friend function
            "let dTag['friendfunc'] = 1
        "endif
    "endif

    " Extending the tag item to a popup item
    let dTag['word']     = sWord
    let dTag['abbr']     = sAbbr
    let dTag['menu']     = sMenu
    let dTag['info']     = sInfo
    let dTag['icase']    = &ignorecase
    let dTag['dup']      = 0
    "let dTag['dup'] = (s:hasPreviewWindow 
                "\&& index(['f', 'p', 'm'], dTag.kind[0]) >= 0)
    return dTag
endfunc
"}}}
" vim:fdm=marker:fen:expandtab:smarttab:fdl=1:
