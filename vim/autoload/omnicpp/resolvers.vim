" Description:  Omnicpp completion resolving functions
" Maintainer:   fanhe <fanhed@163.com>
" Create:       2011 May 15
" License:      GPLv2

" 基本数据结构
"
" TypeInfo, 字典
" {
" 'name':   <name>
" 'til':    <template instantiated list>
" }

" VarInfo, 字典
" {
" 'kind': <'container'|'variable'|'function'|'cast'|'unknown'>
" 'name': <name>
" 'tag': <tag>
" 'typeinfo': <TypeInfo>
" }

" PrmtInfo(模版参数, 函数参数) 字典
" {
" 'kind': <'typename'|'class'|Non Type>
" 'name': <parameter name>
" 'default': <default value>
" }
function! s:StripString(s) "{{{2
    let s = substitute(a:s, '^\s\+', '', 'g')
    let s = substitute(s, '\s\+$', '', 'g')
    return s
endfunc
"}}}
function! s:NewPrmtInfo() "{{{2
    return {'kind': '', 'name': '', 'default': ''}
endfunc
"}}}
function! s:NewTypeInfo() "{{{2
    return {'name': '', 'til': [], 'types': []}
endfunc
"}}}
function! s:NewOmniScope() "{{{2
    return {'kind': 'unknown', 'name': ''}
endfunc
"}}}
" 获取全能补全请求前的语句的 OmniScopeStack
" 以下情况一律先清理所有不必要的括号, 清理 [], 把 C++ 的 cast 转为 C 形式
" case01. A::B C::D::|
" case02. A::B()->C().|    orig: A::B::C(" a(\")z ", '(').|
" case03. A::B().C->|
" case04. A->B().|
" case05. A->B.|
" case06. Z Y = ((A*)B)->C.|
" case07. (A*)B()->C.|
" case08. static_cast<A*>(B)->C.|      -> 处理成标准 C 的形式 ((A*)B)->C.|
" case09. A(B.C()->|)
"
" case10. ::A->|
" case11. A(::B.|)
" case12. (A**)::B.|
"
" Return: OmniInfo
" OmniInfo
" {
" 'omniss': <OmniSS>
" 'precast': <this|<global>|precast>
" }
"
" 列表 OmniSS, 每个条目为 OmniScope
" OmniScope
" {
" 'kind': <'container'|'variable'|'function'|'cast'|'unknown'>
" 'name': <name>
" }
"
" 如 case3, [{'kind': 'container', 'name': 'A'},
"            {'kind': 'function', 'name': 'B'},
"            {'kind': 'variable', 'name': 'C'}]
" 如 case6, [{'kind': 'variable', 'name': 'B'},
"            {'kind': 'variable', 'name': 'C'}]
"
" 判断 cast 的开始: 1. )单词, 2. )(
" 判断 precast: 从 )( 匹配的结束位置寻找匹配的 ), 如果匹配的 ')' 右边也为 ')'
" 判断 postcast: 从 )( 匹配的结束位置寻找匹配的 ), 如果匹配的 ')' 右边不为 ')'
" TODO: 
" 1. A<B>::C<D, E>::F g; g.|
" 2. A<B>::C<D, E>::F.g.| (g 为静态变量)
"
" 1 的方法, 需要记住整条路径每个作用域的 til
" 2 的方法, OmniInfo 增加 til 域
function! omnicpp#resolvers#GetOmniInfo(...) "{{{2
    if a:0 > 0
        if type(a:1) == type('')
            let lTokens = omnicpp#tokenizer#Tokenize(
                        \omnicpp#utils#SimplifyCodeForOmni(a:1))
        elseif type(a:1) == type([])
            let lTokens = a:1
        else
            return []
        endif
    else
        let lTokens = omnicpp#utils#TokenizeStatementBeforeCursor(1)
    endif

    let lRevTokens = reverse(lTokens[:])

    let lOmniSS = []
    let dOmniInfo = {'omniss': [], 'precast': ''}

    " 反向遍历分析
    let idx = 0
    let nLen = len(lRevTokens)

    " 0 -> 期望操作符 ('->', '.', '::')
    " 1 -> 期望单词 ( A|:: )
    " 2 -> 期望左括号 ( A(|). )
    let nState = 0

    " 只有四种需要分辨的符号
    " 1. 作用域或成员操作符 ('::', '.', '->')
    " 2. 单词
    " 3. 左括号
    " 4. 右括号
    let dPrevToken = {}
    while idx < nLen
        let dToken = lRevTokens[idx]

        if dToken.kind == 'cppOperatorPunctuator' 
                    \&& dToken.value =~ '->\|::\|\.'
            if nState == 0
                " 期望操作符, 遇到操作符
                " 切换状态
                let nState = 1 " 期望单词
            elseif nState == 1
                " 期望单词, 遇到操作符
                " 语法错误
                echom 'syntax error: ' . dToken.value
                let lOmniSS = []
                break
            elseif nState == 2
                " 括号状态都已经私自处理完, 这里不再需要了
            endif
        elseif dToken.kind == 'cppWord' 
                    \|| (dToken.kind == 'cppKeyword' && dToken.value ==# 'this')
            if nState == 0
                " 期望操作符, 遇到单词
                " 结束. eg A::B C::|
                "             ^
                break
            elseif nState == 1
                " 成功获取一个单词
                let dOmniScope = s:NewOmniScope()
                let dOmniScope.name = dToken.value
                if dPrevToken.value == '::'
                    let dOmniScope.kind = 'container'
                elseif dPrevToken.value =~# '->\|\.'
                    let dOmniScope.kind = 'variable'
                else
                endif

                " 切换至期望操作符
                let nState = 0

                if dOmniScope.name ==# 'this'
                    let dOmniInfo.precast = 'this'
                else
                    let lOmniSS = [dOmniScope] + lOmniSS
                endif
            elseif nState == 2
                " 括号状态都已经私自处理完, 这里不再需要了
            endif
        elseif dToken.kind == 'cppOperatorPunctuator' && dToken.value == '('
            " eg1: A(B.C()->|)
            "      ^
            " eg2: A(::B.C()->|)
            "      ^
            if dPrevToken.kind == 'cppOperatorPunctuator' 
                        \&& dPrevToken.value == '::'
                let dOmniInfo.precast = '<global>'
            endif
            " 结束
            break
        elseif dToken.kind == 'cppOperatorPunctuator' && dToken.value == ')'
            if nState == 0
                " 期待操作符
                " 遇到右括号
                " 必定是一个 postcast
                " 无须处理, 直接完成
                " eg. (A*)B->|
                "        ^
                break
            elseif nState == 1
                " 期待单词
                " 遇到右括号
                " 可能是 precast 或者 postcast((A)::B.|) 或者是一个函数
                " 判定是否函数
                if lRevTokens[idx+1].value == '(' 
                            \&& lRevTokens[idx+2].kind == 'cppWord'
                    " 是函数
                    let dOmniScope = s:NewOmniScope()
                    let dOmniScope.kind = 'function'
                    let dOmniScope.name = lRevTokens[idx+2].value
                    let lOmniSS = [dOmniScope] + lOmniSS

                    let idx = idx + 2
                    let dToken = lRevTokens[idx]
                    " 切换至期待操作符
                    let nState = 0
                elseif lRevTokens[idx+1].kind == 'cppWord' 
                            \&& dPrevToken.value != '::'
                    " 是一个 precast
                    " eg. ((A*)B)->C.|
                    "          ^

                    " 先添加变量 scope
                    let dOmniScope = s:NewOmniScope()
                    let dOmniScope.kind = 'variable'
                    let dOmniScope.name = lRevTokens[idx+1].value
                    let lOmniSS = [dOmniScope] + lOmniSS

                    " 直接处理完 precast. eg. ((A*)B)|
                    " 寻找匹配的左括号的位置
                    let j = idx + 2
                    try
                        let dTmpToken = lRevTokens[j]
                    catch
                        echom 'syntax error: ' . dToken.value
                        let lOmniSS = []
                        break
                    endtry
                    if dTmpToken.value != ')'
                        echom 'syntax error: ' . dToken.value
                        let lOmniSS = []
                        break
                    endif
                    let j += 1
                    let tmp = 1
                    while j < nLen
                        let dTmpToken = lRevTokens[j]
                        if dTmpToken.value == ')'
                            let tmp += 1
                        elseif dTmpToken.value == '('
                            let tmp -= 1
                            if tmp == 0
                                break
                            endif
                        endif
                        let j += 1
                    endwhile

                    " 添加 precast 信息
                    if lRevTokens[j-1].value =~# 'const\|struct'
                        let dOmniInfo.precast = lRevTokens[j-2].value
                    else
                        let dOmniInfo.precast = lRevTokens[j-1].value
                    endi

                    " 处理完毕
                    break
                elseif dPrevToken.kind == 'cppOperatorPunctuator' 
                            \&& dPrevToken.value == '::'
                    " postcast
                    " eg. (A**)::B.|
                    let dOmniInfo.precast = '<global>'
                    break
                else
                    echom 'syntax error: ' . dToken.value
                    let lOmniSS = []
                    break
                endif
            elseif nState == 2
                " 括号状态都已经私自处理完, 这里不再需要了
            endif
        elseif dToken.kind == 'cppOperatorPunctuator' && dToken.value == ']'
            " Option: 可以在处理前剔除所有 []
            " 处理数组下标
            " eg. A[B][C[D]].|
            if nState == 1 "期待单词时遇到 ']'
                " 跳到匹配的 '['
                let j = idx + 1
                let tmp = 1
                while j < nLen
                    let dTmpToken = lRevTokens[j]
                    if dTmpToken.value == ']'
                        let tmp += 1
                    elseif dTmpToken.value == '['
                        let tmp -= 1
                        if tmp == 0
                            break
                        endif
                    endif
                    let j += 1
                endwhile
                let dToken = dPrevToken " 保持 dPrevToken
                let idx = j
            else
                echom 'syntax error: ' . dToken.value
                let lOmniSS = []
                break
            endif
        elseif dToken.kind == 'cppOperatorPunctuator' && dToken.value == '>'
            " 处理模板实例化
            " eg. A<B, C>::|
            if nState == 1 "期待单词时遇到 '>'
                " 跳到匹配的 '<'
                let j = idx + 1
                let tmp = 1
                while j < nLen
                    let dTmpToken = lRevTokens[j]
                    if dTmpToken.value == '>'
                        let tmp += 1
                    elseif dTmpToken.value == '<'
                        let tmp -= 1
                        if tmp == 0
                            break
                        endif
                    endif
                    let j += 1
                endwhile
                let dToken = dPrevToken " 保持 dPrevToken
                let idx = j
            else
                echom 'syntax error: ' . dToken.value
                let lOmniSS = []
                break
            endif
        else
            " 遇到了其他字符, 结束. 前面判断的结果多数情况下是有用
            if dPrevToken.kind == 'cppOperatorPunctuator' 
                        \&& dPrevToken.value == '::'
                let dOmniInfo.precast = '<global>'
            endif
            break
        endif

        let dPrevToken = dToken
        let idx += 1
    endwhile

    " eg. ::A->|
    if !empty(dPrevToken) && dPrevToken.kind == 'cppOperatorPunctuator' 
                \&& dPrevToken.value == '::'
        let dOmniInfo.precast = '<global>'
    endif

    let dOmniInfo.omniss = lOmniSS
    return dOmniInfo
endfunc
"}}}
" 从 scope 和 name 组合生成 path, 处理烦人的 '<global>'
function! s:GenPath(sScope, sName) "{{{2
    if a:sScope != '<global>'
        return a:sScope . '::' . a:sName
    else
        return a:sName
    endif
endfunc
"}}}
" Return: ScopeInfo
" {
" 'function': [] ,      <- 函数作用域, 一般只用名空间信息
" 'container': [],      <- 容器的作用域列表, 包括名空间
" 'global': []          <- 全局(文件)的作用域列表, 包括名空间
" }
function! omnicpp#resolvers#ResolveScopeStack(lScopeStack) "{{{2
    let dResult = {'function': [], 'container': [], 'global': []}
    let lFunctionScopes = []
    let lContainerScopes = []
    let lGlobalScopes = []

    let lCtnPartScp = []

    let g:dOCppNSAlias = {} " 名空间别名 {'abc': 'std'}
    let g:dOCppUsing = {} " using. eg. {'cout': 'std::out', 'cin': 'std::cin'}

    let nSSLen = len(a:lScopeStack)
    let idx = 0
    while idx < nSSLen
        let dScope = a:lScopeStack[idx]
        if dScope.kind == 'file'
            call add(lGlobalScopes, '<global>')
            call extend(g:dOCppNSAlias, dScope.nsinfo.nsalias)
            call extend(g:dOCppUsing, dScope.nsinfo.using)
            call extend(lGlobalScopes, dScope.nsinfo.usingns)
        elseif dScope.kind == 'container'
            call add(lCtnPartScp, dScope.name)
            call extend(g:dOCppNSAlias, dScope.nsinfo.nsalias)
            call extend(g:dOCppUsing, dScope.nsinfo.using)
            call extend(lContainerScopes, dScope.nsinfo.usingns)
        elseif dScope.kind == 'function'
            " 仅收集 nsinfo
            call extend(g:dOCppNSAlias, dScope.nsinfo.nsalias)
            call extend(g:dOCppUsing, dScope.nsinfo.using)
            call extend(lFunctionScopes, dScope.nsinfo.usingns)
        elseif dScope.kind == 'other'
            " 仅收集 nsinfo
            while idx < nSSLen
                let dScope = a:lScopeStack[idx]
                call extend(g:dOCppNSAlias, dScope.nsinfo.nsalias)
                call extend(g:dOCppUsing, dScope.nsinfo.using)
                " TODO: 应该加到哪里
                call extend(lFunctionScopes, dScope.nsinfo.usingns)
                let idx += 1
            endwhile
            break
        endif

        let idx += 1
    endwhile

    let idx = 0
    while idx < len(lCtnPartScp)
        " 处理嵌套类
        " ['A', 'B', 'C'] -> ['A', 'A::B', 'A::B::C']
        let sCtn = join(lCtnPartScp[:idx], '::')
        " 展开
        let lEpdScp = s:ExpandTagScope(sCtn)
        let lContainerScopes = lEpdScp + lContainerScopes
        "call insert(lContainerScopes, sCtn, 0)

        let idx += 1
    endwhile

    let dResult.function = lFunctionScopes
    let dResult.container = lContainerScopes
    let dResult.global = lGlobalScopes

    return dResult
endfunc
"}}}
" 解析 OmniInfo, 返回用于获取 tags 的 omniTagScopes
function! omnicpp#resolvers#ResolveOmniInfo(lScopeStack, dOmniInfo) "{{{2
    if empty(a:lScopeStack) 
                \|| (empty(a:dOmniInfo.omniss) && a:dOmniInfo.precast ==# '')
        return []
    endif

    let lResult = []
    let dOmniInfo = a:dOmniInfo
    let lOmniSS = dOmniInfo.omniss

    let dScopeInfo = omnicpp#resolvers#ResolveScopeStack(a:lScopeStack)

    let lTagScopes = dScopeInfo.container + dScopeInfo.global 
                \+ dScopeInfo.function
    let lSearchScopes = lTagScopes[:]
    let lMemberStack = lOmniSS[:]

    " 预处理, 主要针对 this-> 和 cast
    if dOmniInfo.precast !=# ''
        " 生成 SearchScopes
        let dNewOmniScope = s:NewOmniScope()

        if dOmniInfo.precast ==# 'this'
            " 亦即把 this-> 替换成 MyCls::
            let dNewOmniScope.name = lSearchScopes[0]
            " precast 为 this 的时候, 直接从 <global> 搜索
            " 因为已把 this 替换为绝对路径的容器. 
            " 即使是嵌套容器的情形, 也能正常工作
            " 或者, 作为另外一个解决方案, 直接在这里解析完毕
            " void A::B()
            " {
            "     this->|
            " }
            let lSearchScopes = dScopeInfo.global
            let dNewOmniScope.kind = 'container'
            let lMemberStack = [dNewOmniScope] + lOmniSS[1:]
        elseif dOmniInfo.precast ==# '<global>'
            " 仅搜索全局作用域以及在全局作用域中的 using namespace
            let lSearchScopes = dScopeInfo.global
        else
            let dNewOmniScope.name = dOmniInfo.precast
            let dNewOmniScope.kind = 'container'
            let lMemberStack = [dNewOmniScope] + lOmniSS[1:]
        endif
    endif

    let lResult = omnicpp#resolvers#ResolveOmniScopeStack(
                \lSearchScopes, lMemberStack, dScopeInfo)

    return lResult
endfunc
"}}}
" 递归解析补全请求的补全 scope
" 返回用于获取 tags 的 TagScopes
function! omnicpp#resolvers#ResolveOmniScopeStack(
            \lSearchScopes, lMemberStack, dScopeInfo) "{{{2
    " TODO: 每次解析变量的 TypeInfo 时, 应该添加此变量的作用域到此类型的搜索域
    " TODO: 类型信息带作用域前缀时(::A), 修正搜索域
    " eg.
    " namespace A
    " {
    "     class B {
    "     };
    "
    "     class C {
    "         B b;
    "     };
    " }
    " b 变量的 TypeInfo {'name': 'B', 'til': []}
    " 搜索变量 B 时需要添加 b 的 scope 的所有可能情况, A::B -> ['A', 'A::B']
    " 开销较大, 暂不实现
    let lSearchScopes = a:lSearchScopes
    let dScopeInfo = a:dScopeInfo
    let lOrigScopes = dScopeInfo.container + dScopeInfo.global 
                \+ dScopeInfo.function
    " 基本分析方法
    " 1. 解析 member 的实际类型, 并修正 SearchScopes
    "    1) 如果是容器, 无须解析
    "    2) 如果是变量, 在作用域中搜索此变量, 然后确定其类型
    "    3) 如果是函数, 在作用域中搜索此函数, 然后确定其返回类型
    " 2. 依次在当前有效 SearchScopes 搜索, 从局部到外部, 取首次成功获取的 tag
    " 3. 解析 tag 获取新的 SearchScopes, 重复, 直至遍历 MemberStack 完毕

    let lMemberStack = a:lMemberStack
    let nLen = len(lMemberStack)
    let idx = 0
    while idx < nLen
        let dMember = lMemberStack[idx]
        " 当前搜索用名称, member 的类型不是 'container', 需要解析
        " NOTE: 可接受带作用域的名字, 因为搜索 tags 是会合成为 path
        let sCurName = dMember.name

        let dMember.typeinfo = s:NewTypeInfo()

        if dMember.kind == 'container'
            let sCurName = dMember.name
            let dTypeInfo = s:NewTypeInfo()
            let dTypeInfo.name = dMember.name
            let dMember.typeinfo = dTypeInfo

            if idx == 0
                " 起点容器需要展开名空间信息
                let dTypeInfo.name = s:ExpandUsingAndNSAlias(dTypeInfo.name)
                let sCurName = dTypeInfo.name
            endif
        elseif dMember.kind == 'variable'
            if idx == 0
                let lSearchScopes = lOrigScopes
                " 第一次进入, 因为 ctags 不支持局部变量, 
                " 所以如果起点为变量时, 需要分析是否在当前局部作用域内定义了
                let dTypeInfo = omnicpp#resolvers#ResolveFirstVariable(
                            \lSearchScopes, dMember.name)

                if len(dTypeInfo.types) >= 2
                    let lTmpName = substitute(dTypeInfo.name, '::\w\+$', '', '')
                    let dCtnTag = s:GetFirstMatchTag(lSearchScopes, lTmpName)
                    let lCtnTil = dTypeInfo.types[-2].til
                    let dReplTypeInfo = s:ResolveFirstVariableTypeReplacement(
                                \dTypeInfo.name, dCtnTag, lCtnTil)
                    if !empty(dReplTypeInfo)
                        " 先展开搜索域
                        let lSearchScopes = s:ExpandSearchScopes(
                                    \[dTypeInfo.name] + lSearchScopes)
                        " 再替换类型信息
                        call extend(dTypeInfo, dReplTypeInfo, 'force')
                    endif
                endif

                if dTypeInfo.name =~# '^::\w\+'
                    let dTypeInfo.name = dTypeInfo.name[2:]
                    "修正搜索域为仅搜索全局作用域
                    let lOrigScopes = dScopeInfo.global
                    let lSearchScopes = lOrigScopes
                endif
                let dTmpTag = s:GetFirstMatchTag(lSearchScopes, dTypeInfo.name)
                let dMember.typeinfo = dTypeInfo
                let dMember.tag = dTmpTag
                if !empty(dTmpTag)
                    let lSearchScopes = omnicpp#resolvers#ResolveTag(
                                \dTmpTag, dMember.typeinfo)
                    let idx += 1
                    continue
                else
                    " 肯定有错误
                    let lSearchScopes = []
                    break
                endif
            else
                " 常规处理
                let dTmpTag = s:GetFirstMatchTag(lSearchScopes, dMember.name)

                if has_key(dTmpTag, 'typeref')
                    " 变量可能是无名容器的成员, 如果是无名容器成员,
                    " 直接设置 SearchScopes 然后跳过这一步
                    " 因为不会存在无名容器的 path
                    let lTyperef = split(dTmpTag.typeref, '\w\zs:\ze\w')
                    let sKind = lTyperef[0]
                    let sAnon = lTyperef[1]
                    if sAnon =~# '^__anon\d\+'
                        let lSearchScopes = [sAnon]
                        let idx += 1
                        continue
                    endif
                endif

                if !empty(dTmpTag)
                    let szDecl = dTmpTag.cmd
                    let dTypeInfo = s:GetVariableTypeInfo(szDecl[2:-3], 
                                \dTmpTag.name)
                    let dMember.typeinfo = dTypeInfo
                    let dMember.tag = dTmpTag

                    try
                        let sCurName = omnicpp#resolvers#ResolveTemplate(
                                    \dMember, lMemberStack[idx-1])
                    catch
                        " 语法错误
                        let lSearchScopes = []
                        break
                    endtry

                    "let lSearchScopes = lOrigScopes
                    " 首先从变量所属的作用域内搜索
                    " eg. std::map::iterator = iterator -> std::map, std
                    let lSearchScopes = lSearchScopes + lOrigScopes
                endif
            endif
        elseif dMember.kind == 'function'
            if idx == 0
                " 若为起点, 特殊处理
                " 先处理名空间问题
                let dMember.name = s:ExpandUsingAndNSAlias(dMember.name)
                let dTmpTag = s:GetFirstMatchTag(lSearchScopes, dMember.name)
                if empty(dTmpTag)
                    let lSearchScopes = []
                    break
                endif

                " 暂时添加一级搜索域, 不支持嵌套, 主要用于支持 stl
                if lSearchScopes[0] != dTmpTag.scope
                    call insert(lSearchScopes, dTmpTag.scope, 0)
                endif

                let dTypeInfo = s:GetVariableTypeInfoFromQualifiers(
                            \dTmpTag.qualifiers)
                let dMember.typeinfo = dTypeInfo
                let sCurName = dTypeInfo.name
            else
                let dTmpTag = s:GetFirstMatchTag(lSearchScopes, dMember.name)
                if empty(dTmpTag)
                    let lSearchScopes = []
                    break
                endif

                let dTypeInfo = s:GetVariableTypeInfoFromQualifiers(
                            \dTmpTag.qualifiers)
                if dTypeInfo.name != ''
                    let dMember.typeinfo = dTypeInfo
                    let dMember.tag = dTmpTag

                    try
                        let sCurName = omnicpp#resolvers#ResolveTemplate(
                                    \dMember, lMemberStack[idx-1])
                    catch
                        let lSearchScopes = []
                        break
                    endtry

                    "let lSearchScopes = lOrigScopes
                    " 首先从变量所属的作用域内搜索
                    let lSearchScopes = lSearchScopes + lOrigScopes
                endif
            endif
        endif

        "=======================================================================

        if dMember.kind !=# 'container'
            " 只有类型为非容器的时候, 
            " 即在 OmniScopeStack 中算作新的容器起点的时候
            " 在获取匹配的标签前, 才需要展开搜索域
            " eg. A.B->C()->| -> B-> 和 C()-> 的时候都要展开搜索域为搜索域栈
            let lSearchScopes = s:ExpandSearchScopes(lSearchScopes)
        endif

        let dCurTag = s:GetFirstMatchTag(lSearchScopes, sCurName)

        " 处理硬替换类型
        if !empty(dCurTag) && has_key(g:dOCppTypes, dCurTag.path)
            let sReplacement = g:dOCppTypes[dCurTag.path]
            let dReplTypeInfo = s:GetVariableTypeInfo(sReplacement, '')

            if !empty(dReplTypeInfo.til)
                " 处理模版, 当前成员所属容器的声明列表和实例化列表修正 til
                " eg.
                " template <typename A, typename B> class C {
                "     typedef Z Y;
                " }
                " C<a, b>
                " Types:    C::Y =  X<B, A>
                " Result:   C::Y -> X<b, a>
                let dCtnInfo = lMemberStack[idx-1]
                let lPrmtInfo = 
                            \s:GetTemplatePrmtInfoList(dCtnInfo.tag.qualifiers)
                let dTmpMap = {}
                for nTmpIdx in range(len(dCtnInfo.typeinfo.til))
                    let dTmpMap[lPrmtInfo[nTmpIdx].name] = 
                                \dCtnInfo.typeinfo.til[nTmpIdx]
                endfor
                for nTmpIdx in range(len(dReplTypeInfo.til))
                    let dReplTilTI = omnicpp#utils#GetVariableType(
                                \dReplTypeInfo.til[nTmpIdx])
                    if has_key(dTmpMap, dReplTilTI.name)
                        let dReplTypeInfo.til[nTmpIdx] = 
                                    \dTmpMap[dReplTilTI.name]
                    endif
                endfor
            else
                " 无模版的变量替换
                let dCtnInfo = lMemberStack[idx-1]
                let lPrmtInfo = 
                            \s:GetTemplatePrmtInfoList(dCtnInfo.tag.qualifiers)
                let dTmpMap = {}
                for nTmpIdx in range(len(dCtnInfo.typeinfo.til))
                    let dTmpMap[lPrmtInfo[nTmpIdx].name] = 
                                \dCtnInfo.typeinfo.til[nTmpIdx]
                endfor
                if has_key(dTmpMap, dReplTypeInfo.name)
                    let dReplTypeInfo.name = dTmpMap[dReplTypeInfo.name]
                endif
            endif
            " 替换类型信息
            let dMember.typeinfo = dReplTypeInfo

            let dCurTag = s:GetFirstMatchTag(lSearchScopes, dReplTypeInfo.name)
        endif

        let dMember.tag = dCurTag
        let lSearchScopes = omnicpp#resolvers#ResolveTag(
                    \dCurTag, dMember.typeinfo)

        let idx += 1
    endwhile

    return lSearchScopes
endfunc
"}}}
" 处理类型替换
" Param1: sTypeName, 当前需要替换的类型名, 绝对路径. eg. std::map::iterator
" Param2: dCtnInfo, 需要处理的类型所属容器的信息, 主要用到它的 tag 和 typeinfo
"         相当于上一个 MemberStack
" Return: 替换后的类型信息 TypeInfo
" 这个替换不完善, 只对以下情况有效
" eg. std::map::iterator=pair<_Key, _Tp>
" 替换的类型中的模板初始化列表对应原始类型的 scope 的模板初始化列表
" 对于更复杂的情况, 不予支持
function! s:ResolveFirstVariableTypeReplacement(
            \sTypeName, dCtnTag, lCtnTil) "{{{2
    let sTypeName = a:sTypeName
    let dCtnTag = a:dCtnTag
    let lCtnTil = a:lCtnTil
    let dResult = {}
    " 处理硬替换类型
    if sTypeName !=# '' && has_key(g:dOCppTypes, sTypeName)
        let sReplacement = g:dOCppTypes[sTypeName]
        let dReplTypeInfo = s:GetVariableTypeInfo(sReplacement, '')

        if !empty(dReplTypeInfo.til)
            " 处理模版, 当前成员所属容器的声明列表和实例化列表修正 til
            " eg.
            " template <typename A, typename B> class C {
            "     typedef Z Y;
            " }
            " C<a, b>
            " Types:    C::Y =  X<B, A>
            " Result:   C::Y -> X<b, a>
            let lPrmtInfo = 
                        \s:GetTemplatePrmtInfoList(dCtnTag.qualifiers)
            let dTmpMap = {}
            for nTmpIdx in range(len(lCtnTil))
                let dTmpMap[lPrmtInfo[nTmpIdx].name] = lCtnTil[nTmpIdx]
            endfor
            for nTmpIdx in range(len(dReplTypeInfo.til))
                let dReplTilTI = omnicpp#utils#GetVariableType(
                            \dReplTypeInfo.til[nTmpIdx])
                if has_key(dTmpMap, dReplTilTI.name)
                    let dReplTypeInfo.til[nTmpIdx] = 
                                \dTmpMap[dReplTilTI.name]
                endif
            endfor
        else
            " 无模版的变量替换
            let lPrmtInfo = 
                        \s:GetTemplatePrmtInfoList(dCtnTag.qualifiers)
            let dTmpMap = {}
            for nTmpIdx in range(len(lCtnTil))
                let dTmpMap[lPrmtInfo[nTmpIdx].name] = lCtnTil[nTmpIdx]
            endfor
            if has_key(dTmpMap, dReplTypeInfo.name)
                let dReplTypeInfo.name = dTmpMap[dReplTypeInfo.name]
            endif
        endif

        let dResult = dReplTypeInfo
    endif

    return dResult
endfunc
"}}}
" 展开搜索域, 深度优先
" eg. ['A::B', 'C::D::E', 'F'] -> 
"     ['A::B', 'A', '<global>', 'C::D::E', 'C::D', 'C', 'F']
function! s:ExpandSearchScopes(lSearchScopes) "{{{2
    let lSearchScopes = a:lSearchScopes
    let lResult = []
    let dGuard = {}
    for lSearchScope in lSearchScopes
        let lSearchScopesStack = s:GetSearchScopeStackFromPath(lSearchScope)
        for sSearchScope in lSearchScopesStack
            if !has_key(dGuard, sSearchScope)
                call add(lResult, sSearchScope)
                let dGuard[sSearchScope] = 1
            endif
        endfor
    endfor

    return lResult
endfunc
"}}}
" 展开 TagScope, 主要针对类. eg. A -> ['A', 'B', 'C']
function! s:ExpandTagScope(sTagScope) "{{{2
    let sTagScope = a:sTagScope
    let lResult = [sTagScope]

    if sTagScope != '<global>'
        let lTags = g:GetTagsByPath(sTagScope)
        if !empty(lTags)
            let dTag = lTags[0]
            let lResult = omnicpp#resolvers#ResolveTag(dTag)
        endif
    endif

    return lResult
endfunc
"}}}
" 把作用域路径展开为搜索域栈, 返回的搜索域栈的栈顶包括作为参数输入的路径
" eg. A::B::C -> ['A::B::C', 'A::B', 'A', <global>]
function! s:GetSearchScopeStackFromPath(sPath) "{{{2
    let sPath = a:sPath
    let lResult = []
    if sPath ==# ''
        let lResult = []
    elseif sPath ==# '<global>'
        let lResult = ['<global>']
    else
        let lScopes = split(sPath, '::')
        call insert(lResult, '<global>')
        for idx in range(len(lScopes))
            if idx == 0
                call insert(lResult, lScopes[idx])
            else
                call insert(lResult, lResult[0] . '::' . lScopes[idx])
            endif
        endfor
    endif

    return lResult
endfunc
"}}}
function! s:GetTemplatePrmtInfo(sDecl) "{{{2
    let bak_ic = &ic
    set noic

    let sDecl = s:StripString(a:sDecl)
    let dPrmtInfo = s:NewPrmtInfo()
    if sDecl =~# '^typename\|^class'
        " 类型参数
        let dPrmtInfo.kind = matchstr(sDecl, '^\w\+')
        if sDecl =~# '='
            " 有默认值
            let dPrmtInfo.name = matchstr(sDecl, '\w\+\ze\s*=')
            let dPrmtInfo.default = matchstr(sDecl, '=\s*\zs\S\+\ze$')
        else
            " 无默认值
            let dPrmtInfo.name = matchstr(sDecl, '\w\+$')
        endif
    else
        " 非类型参数
        let dPrmtInfo.kind = matchstr(sDecl, '^\S\+\ze[*& ]\+\w\+')
        if sDecl =~# '='
            " 有默认值
            let dPrmtInfo.name = matchstr(sDecl, '\w\+\ze\s*=')
            let dPrmtInfo.default = matchstr(sDecl, '=\s*\zs\S\+\ze$')
        else
            " 无默认值
            let dPrmtInfo.name = matchstr(sDecl, '\w\+$')
        endif
    endif

    let &ic = bak_ic
    return dPrmtInfo
endfunc
"}}}
function! s:GetTemplatePrmtInfoList(sQualifiers) "{{{2
    let sQualifiers = a:sQualifiers
    if sQualifiers == ''
        return []
    endif

    let lResult = []

    let idx = 0
    let nNestDepth = 0
    let nLen = len(sQualifiers)
    let nSubStart = 0
    while idx < nLen
        let c = sQualifiers[idx]
        if c == '<'
            let nNestDepth += 1
            if nNestDepth == 1
                let nSubStart = idx + 1
            endif
        elseif c == '>'
            let nNestDepth -= 1
            if nNestDepth == 0
                let sText = sQualifiers[nSubStart : idx - 1]
                let dPrmtInfo = s:GetTemplatePrmtInfo(sText)
                call add(lResult, dPrmtInfo)
                break
            endif
        elseif c == ','
            if nNestDepth == 1
                let sText = sQualifiers[nSubStart : idx - 1]
                let dPrmtInfo = s:GetTemplatePrmtInfo(sText)
                call add(lResult, dPrmtInfo)
                let nSubStart = idx + 1
            endif
        endif

        let idx += 1
    endwhile

    return lResult
endfunc
"}}}
" Param: sInstDecl 为实例化声明. eg. A<B, C<D>, E> Z;
" Return:   模版实例化列表
function! s:GetTemplateInstList(sInstDecl) "{{{2
    let s = a:sInstDecl
    let til = []

    let idx = 0
    let nCount = 0
    let s1 = 0
    while idx < len(s)
        let c = s[idx]
        if c == '<'
            let nCount += 1
            if nCount == 1
                let s1 = idx + 1
            endif
        elseif c == '>'
            let nCount -= 1
            if nCount == 0
                let sArg = s:StripString(s[s1 : idx-1])
                if sArg != ''
                    call add(til, sArg)
                endif
                break
            endif
        elseif c == ','
            if nCount == 1
                let sArg = s:StripString(s[s1 : idx-1])
                if sArg != ''
                    call add(til, sArg)
                endif
                let s1 = idx + 1
            endif
        endif

        let idx += 1
    endwhile

    return til
endfunc
"}}}
" Return: 与 TypeInfo 一致的字典
"         eg. [{'name': 'A', 'til': ['B', 'C<D>']}, {'name': 'B', 'til': []}]
function! s:GetInheritsInfoList(sInherits) "{{{2
    let sInherits = a:sInherits
    if sInherits == ''
        return []
    endif

    let lResult = []

    let idx = 0
    let nNestDepth = 0
    let nLen = len(sInherits)
    let nSubStart = 0
    while idx < nLen
        let c = sInherits[idx]
        if c == '<'
            let nNestDepth += 1
        elseif c == '>'
            let nNestDepth -= 1
        elseif c == ','
            if nNestDepth == 0
                let sText = sInherits[nSubStart : idx - 1]
                let dInfo = {}
                let dInfo.name = matchstr(sText, '^\s*\zs\w\+\ze\s*<\?')
                let dInfo.til = s:GetTemplateInstList(sText)
                call add(lResult, dInfo)
                let nSubStart = idx + 1
            endif
        endif

        let idx += 1
    endwhile

    let sText = sInherits[nSubStart : idx - 1]
    let dInfo = {}
    let dInfo.name = matchstr(sText, '^\s*\zs\w\+\ze\s*<\?')
    let dInfo.til = s:GetTemplateInstList(sText)
    call add(lResult, dInfo)
    let nSubStart = idx + 1

    return lResult
endfunc
"}}}
" 在数个 TagScope 中获取第一个匹配的 tag
" 可选参数为需要匹配的类型. eg. s:GetFirstMatchTag(lTagScopes, 'A', 'c', 's')
function! s:GetFirstMatchTag(lTagScopes, sName, ...) "{{{2
    if a:sName == ''
        return {}
    endif

    let dTag = {}
    for sScope in a:lTagScopes
        let sPath = s:GenPath(sScope, a:sName)
        let lTags = g:GetTagsByPath(sPath)
        if !empty(lTags)
            if empty(a:000)
                let dTag = lTags[0]
                if (dTag.parent ==# dTag.name || '~'.dTag.parent ==# dTag.name) 
                            \&& dTag.kind =~# 'f\|p'
                    " 跳过构造和析构函数的 tag, 因为构造函数是不能继续补全的
                    " eg. A::A, A::~A
                    continue
                else
                    break
                endif
            else
                " 处理要求的匹配类型
                let bFound = 0
                for dTmpTag in lTags
                    if index(a:000, dTmpTag.kind) >= 0
                        let dTag = dTmpTag
                        let bFound = 1
                        break
                    endif
                endfor

                if bFound
                    break
                endif
            endif
        endif
    endfor
    return dTag
endfunc
"}}}
" 从声明中获取变量的类型
" eg. A<B, C<D> > -> {'name': 'A', 'til': ['B', 'C<D>']}
" Return: TypeInfo
function! s:GetVariableTypeInfo(sDecl, sVar) "{{{2
    let dTypeInfo = s:NewTypeInfo()
    let bak_ic = &ic
    set noic

    " FIXME: python 的字典转为 vim 字典时, \t 全部丢失
    let sDecl = substitute(a:sDecl, '\\t', ' ', 'g')
    let sVar = a:sVar

    let dTypeInfo = omnicpp#utils#GetVariableType(sDecl, sVar)

    let &ic = bak_ic
    return dTypeInfo
endfunc
"}}}
" 从限定词中解析变量类型
function! s:GetVariableTypeInfoFromQualifiers(sQualifiers) "{{{2
    return s:GetVariableTypeInfo(a:sQualifiers, '')
endfunc
"}}}
" 剔除配对的字符里面(包括配对的字符)的内容
" 可选参数为深度, 从 1 开始, 默认为 1
function! s:StripPair(sString, sPairL, sPairR, ...) "{{{2
    let sString = a:sString
    let sPairL = a:sPairL
    let sPairR = a:sPairR
    let nDeep = 1
    if a:0 > 0
        let nDeep = a:1
    endif

    if nDeep <= 0
        return sString
    endif

    let sResult = ''

    let idx = 0
    let nLen = len(sString)
    let nCount = 0
    let nSubStart = 0
    while idx < nLen
        let c = sString[idx]
        if c == sPairL
            let nCount += 1
            if nCount == nDeep && nSubStart != -1
                let sResult .= sString[nSubStart : idx - 1]
                let nSubStart = -1
            endif
        elseif c == sPairR
            let nCount -= 1
            if nCount == nDeep - 1
                let nSubStart = idx + 1
            endif
        endif
        let idx += 1
    endwhile

    if nSubStart != -1
        let sResult .= sString[nSubStart : -1]
    endif

    return sResult
endfunc
"}}}
" 解析 tag 的 typeref 和 inherits
" NOTE1: dTag 和 可选参数都可能修改而作为输出
" NOTE2: 近解析出最临近的搜索域, 不展开次邻近等的搜索域
" eg. A::B::C -> 'A::B::C::' x->x 'A::B::C', 'A::B', 'A', '<global>'
" 可选参数为 TypeInfo, 作为输出, 会修改, 用于类型为模版类的情形
" NOTE3: 仅需修改派生类的类型信息作为输出,
"        因为基类的类型定义会在模版解析(ResolveTemplate())的时候处理,
"        模版解析时近需要派生类的标签和类型信息
" Return: 与 tag.path 同作用域的 scope 列表
function! omnicpp#resolvers#ResolveTag(dTag, ...) "{{{2
    let lTagScopes = []
    let dTag = a:dTag

    if empty(dTag)
        return lTagScopes
    endif

    if a:0 > 0
        let dTypeInfo = a:1
    else
        let dTypeInfo = s:NewTypeInfo()
    endif

    let lInherits = []

    " NOTE: 限于 ctags 的能力, 很多 C++ 的类型定义都没有 'typeref' 域
    " 这两个属性不会同时存在?! 'typeref' 比 'inherits' 优先?!
    while has_key(dTag, 'typeref') || dTag.kind ==# 't'
        if has_key(dTag, 'typeref')
            let lTyperef = split(dTag.typeref, '\w\zs:\ze\w')
            let sKind = lTyperef[0]
            let sPath = lTyperef[1]
            " TODO: 如果是无名容器(eg. MyNs::__anon1), 直接添加到 TagScopes,
            " 因为不会存在无名容器的 path
            let lTags = g:GetTagsByKindAndPath(sKind, sPath)
            if empty(lTags)
                break
            else
                let dTag = lTags[0]
            endif
        else
            " eg. typedef basic_string<char> string;
            " 从模式中提取类型信息
            let sDecl = matchstr(dTag.cmd[2:-3], '\Ctypedef\s\+\zs.\+')
            let sDecl = matchstr(sDecl, '\C.\{-1,}\ze\s\+\<' . dTag.name . '\>')
            let dTmpTypeInfo = s:GetVariableTypeInfo(sDecl, dTag.name)

            " 修正 TypeInfo
            let dTypeInfo.name = dTmpTypeInfo.name
            let dTypeInfo.til = dTmpTypeInfo.til

            " 生成搜索域
            " eg. 'path': 'A::B::C'
            " SearchScopes = ['A::B', 'A', '<global>']
            let lPaths = split(dTag.path, '::')[:-2]
            let lTmpSearchScopes = ['<global>']
            for nTmpIdx in range(len(lPaths))
                if nTmpIdx == 0
                    call insert(lTmpSearchScopes, lPaths[nTmpIdx])
                else
                    call insert(lTmpSearchScopes, 
                                \lTmpSearchScopes[0] . lPaths[nTmpIdx])
                endif
            endfor

            let dTmpTag = s:GetFirstMatchTag(
                        \lTmpSearchScopes, dTmpTypeInfo.name)
            if empty(dTmpTag)
                break
            else
                "let dTag = dTmpTag
                " 同时修正 Tag
                call filter(dTag, 0)
                call extend(dTag, dTmpTag)
            endif
        endif
    endwhile

    let lTagScopes += [dTag.path]

    if has_key(dTag, 'inherits')
        let lInherits += split(s:StripPair(dTag.inherits, '<', '>'), ',')
    endif

    for parent in lInherits
        " NOTE: 无需处理模版类的继承, 因为会在 ResolveTemplate() 中处理
        "let sPath = s:GenPath(dTag.scope, parent)

        "let lTags = g:GetTagsByKindAndPath('c', sPath)
        "if !empty(lTags)
            "let lTagScopes += omnicpp#resolvers#ResolveTag(lTags[0])
        "endif
        let lSearchScopeStack = s:GetSearchScopeStackFromPath(dTag.scope)
        let dTmpTag = s:GetFirstMatchTag(lSearchScopeStack, parent, 'c', 's')
        if !empty(dTmpTag)
            let lTagScopes += omnicpp#resolvers#ResolveTag(dTmpTag)
        endif
    endfor

    return lTagScopes
endfunc
"}}}
" 在指定的 SearchScopes 中解析补全中的第一个变量的具体类型
" Return: TypeInfo
function! omnicpp#resolvers#ResolveFirstVariable(lSearchScopes, sVariable) "{{{2
    " 1. 首先在局部作用域中查找声明
    " 2. 如果查找成功, 直接返回, 否则再在 SearchScopes 中查找声明
    let dTypeInfo = omnicpp#resolvers#SearchLocalDecl(a:sVariable)
    let sVarType = dTypeInfo.name

    if sVarType != ''
        " 局部变量, 必须展开 using 和名空间别名
        let dTypeInfo.name = s:ExpandUsingAndNSAlias(dTypeInfo.name)
    else
        " 没有在局部作用域到找到此变量的声明
        " 在作用域栈中搜索
        let dTag = s:GetFirstMatchTag(a:lSearchScopes, a:sVariable)
        if !empty(dTag)
            let sDecl = dTag.cmd
            let dTypeInfo = s:GetVariableTypeInfo(sDecl[2:-3], dTag.name)
            if has_key(dTag, 'class')
                " 变量是类中的成员, 需要解析模版
                let lTags = g:GetTagsByPath(a:lSearchScopes[0])
                if !empty(lTags)
                    let dCtnTag = lTags[0]
                    call omnicpp#resolvers#DoResolveTemplate(
                                \dCtnTag, [], dTag.parent, dTypeInfo)
                endif
            endif
        endif
    endif

    return dTypeInfo
endfunc
"}}}
" 展开 using 和名空间别名
function! s:ExpandUsingAndNSAlias(sName) "{{{2
    let sVarType = a:sName
    if sVarType == ''
        return ''
    endif

    " 处理 using
    if has_key(g:dOCppUsing, sVarType)
        let sVarType = g:dOCppUsing[sVarType]
    endif

    " 可能嵌套. namespace A = B::C; using A::Z;
    let sFirstWord = split(sVarType, '::')[0]
    while has_key(g:dOCppNSAlias, sFirstWord)
        let sVarType = join(
                    \[g:dOCppNSAlias[sFirstWord]] + split(sVarType, '::')[1:], 
                    \'::')
        let sFirstWord = split(sVarType, '::')[0]
    endwhile

    return sVarType
endfunc
"}}}
" 解析模版
" Param1: 当前变量信息
" Param2: 包含 Param1 成员的容器变量信息
" Return: 解析完成的 TB (typename) 的具体值(实例化后的类型名)
function! omnicpp#resolvers#ResolveTemplate(dCurVarInfo, dCtnVarInfo) "{{{2
    " 同时处理类内的模版补全
    " 如果在类内要求补全模版, 因为没有 til, 所以需要检查 til
    let dCurVarInfo = a:dCurVarInfo
    let dCtnVarInfo = a:dCtnVarInfo
    let lInstList = a:dCtnVarInfo.typeinfo.til

    let nResult = 0

    if !has_key(dCurVarInfo.tag, 'class') && !has_key(dCurVarInfo.tag, 'struct')
        " 不是类成员
        return ''
    endif

    let nResult = omnicpp#resolvers#DoResolveTemplate(
                \dCtnVarInfo.tag, lInstList, 
                \dCurVarInfo.tag.parent, dCurVarInfo.typeinfo)

    return dCurVarInfo.typeinfo.name
endfunc
"}}}
" 递归解析继承树的模版
" 在 dClassTag 类中查找 sMatchClass 类的类型 sTypeName
" eg.
" A<B, C> foo; foo.b.|
" A         -> dClassTag = {...}
" A         -> sMatchClass = 'A' (如果没有基类的话)
" <B, C>    -> lInstList = ['B', 'C']
" b         -> dTypeInfo = {'name': 'B', 'til': ...} (作为输出, 可能整个都修改)
" Return: 0 表示未完成, 1 表示完成
function! omnicpp#resolvers#DoResolveTemplate(
            \dClassTag, lInstList, sMatchClass, dTypeInfo) "{{{2
    let dClassTag = a:dClassTag
    let lInstList = a:lInstList
    let sMatchClass = a:sMatchClass
    let dTypeInfo = a:dTypeInfo

    let bak_ic = &ic
    set noic

    " 当前解析的类的模版声明参数表
    let lPrmtInfo = s:GetTemplatePrmtInfoList(dClassTag.qualifiers)
    " 如果模版实例化列表为空(例如在类中补全), 用声明列表代替
    if empty(lInstList)
        for dPrmtInfo in lPrmtInfo
            if dPrmtInfo.default != ''
                call add(lInstList, dPrmtInfo.default)
            else
                call add(lInstList, dPrmtInfo.name)
            endif
        endfor
    endif

    let nResult = 0

    if dClassTag.name == sMatchClass
        " 找到了需要找的类
        " 开始替换
        " 直接文本替换
        if empty(dTypeInfo.til)
            " 变量不是模版类
            let idx = 0
            while idx < len(lPrmtInfo)
                let dPrmtInfo = lPrmtInfo[idx]
                if dTypeInfo.name == dPrmtInfo.name
                    if idx < len(lInstList)
                        "let dTypeInfo.name = lInstList[idx]
                        " 修改整个 TypeInfo
                        call filter(dTypeInfo, 0)
                        call extend(dTypeInfo, 
                                    \s:GetVariableTypeInfo(lInstList[idx], ''))
                    else
                        " 再检查是否有默认参数, 否则肯定语法错误
                        if dPrmtInfo.default != ''
                            let dTypeInfo.name = dPrmtInfo.default
                        else
                            let &ic = bak_ic
                            throw 'C++ Syntax Error'
                        endif
                    endif
                    " 已经找到, 无论如何都要 break
                    break
                endif
                let idx += 1
            endwhile
        else
            " 变量是模版类, 需逐个替换模版实例化参数
            " TODO: 不应该嵌套替换, 应该分离出 token, 替换, 然后用空格合成,
            " 开销较大
            let idx = 0
            while idx < len(dTypeInfo.til)
                let idx2 = 0
                while idx2 < len(lPrmtInfo)
                    let dPrmtInfo = lPrmtInfo[idx2]
                    if idx2 < len(lInstList)
                        let sNewVaue = lInstList[idx2]
                    else
                        " 检查默认值
                        if dPrmtInfo.default != ''
                            let sNewVaue = dPrmtInfo.default
                        else
                            let &ic = bak_ic
                            throw 'C++ Syntax Error'
                        endif
                    endif
                    let dTypeInfo.til[idx] = substitute(
                                \dTypeInfo.til[idx], 
                                \'\<'.dPrmtInfo.name.'\>', 
                                \sNewVaue, 
                                \'g')

                    let idx2 += 1
                endwhile

                let idx += 1
            endwhile
        endif
        let nResult = 1 " 解析完毕
    else
        if !has_key(dClassTag, 'inherits')
            " 查找失败
            let nResult = 0
        else
            " TODO: 如果继承的类是类型定义 eg. typedef A<B, C> D;
            " 需要先解析完成类型定义
            let sInherits = dClassTag.inherits
            let lInheritsInfoList = 
                        \s:GetInheritsInfoList(dClassTag.inherits)
            " 深度优先搜索
            for dInheritsInfo in lInheritsInfoList
                " TODO: 先搜索最邻近作用域
                let lTags = g:GetTagsByPath(dInheritsInfo.name)
                if empty(lTags)
                    " 应该有语法错误或者 tags 数据库不是最新
                    let nResult = 0
                    break
                endif

                let dInheritsTag = lTags[0]
                " 逐个替换 dInheritsInfo.til 的项目
                if empty(dInheritsInfo.til)
                    " 非模版类, 直接替换类型名文本
                    let idx = 0
                    while idx < len(lPrmtInfo)
                        let dPrmtInfo = lPrmtInfo[idx]
                        if dInheritsInfo.name == dPrmtInfo.name
                            if idx < len(lInstList)
                                let dInheritsInfo.name = lInstList[idx]
                            else
                                " 检查默认参数
                                if dPrmtInfo.default != ''
                                    let dInheritsInfo.name = dPrmtInfo.name
                                else
                                    let &ic = bak_ic
                                    throw 'C++ Syntax Error'
                                endif
                            endif
                            " 已经找到, 无论如何都要 break
                            break
                        endif
                        let idx += 1
                    endwhile
                else
                    " 模版类, 逐个处理模版实例化参数
                    let idx = 0
                    while idx < len(dInheritsInfo.til)
                        let idx2 = 0
                        while idx2 < len(lPrmtInfo)
                            let dPrmtInfo = lPrmtInfo[idx2]
                            if idx2 < len(lInstList)
                                let sNewVaue = lInstList[idx2]
                            else
                                " 检查默认值
                                if dPrmtInfo.default != ''
                                    let sNewVaue = dPrmtInfo.default
                                else
                                    let &ic = bak_ic
                                    throw 'C++ Syntax Error'
                                endif
                            endif
                            let dInheritsInfo.til[idx] = substitute(
                                        \dInheritsInfo.til[idx], 
                                        \'\<'.dPrmtInfo.name.'\>', 
                                        \sNewVaue, 
                                        \'g')

                            let idx2 += 1
                        endwhile

                        let idx += 1
                    endwhile
                endif

                let nRet = omnicpp#resolvers#DoResolveTemplate(dInheritsTag, 
                            \dInheritsInfo.til, sMatchClass, dTypeInfo)
                if nRet
                    " 已解决
                    let nResult = nRet
                    break
                endif
            endfor
        endif
    endif

    let &ic = bak_ic
    return nResult
endfunc
"}}}
" 比较两个光标位置 
function! s:CmpPos(lPos1, lPos2) "{{{2
    let lPos1 = a:lPos1
    let lPos2 = a:lPos2
    if lPos1[0] > lPos2[0]
        return 1
    elseif lPos1[0] < lPos2[0]
        return -1
    else
        if lPos1[1] > lPos2[1]
            return 1
        elseif lPos1[1] < lPos2[1]
            return -1
        else
            return 0
        endif
    endif
endfunc
"}}}
" 获取向上搜索局部变量的停止位置, 同时是也是向下搜索的开始位置
" Note: 如果光标不在任何 '局部' 作用域中, 即为全局作用域, 返回 [0, 0]
"       全局作用域不应调用此函数
" eg.
" class A {
"     char foo;
"     class B {
"         void F()
"         {
"             long foo;
"         }
"         short foo;
"         void Func(int foo)
"         {
"             foo = 0;|
"         }
"     };
" };
" TODO: 处理 extern "C" {
function! s:GetStopPosForLocalDeclSearch(...) "{{{2
    let lOrigCursor = getpos('.')
    let lOrigPos = lOrigCursor[1:2]
    let lStopPos = lOrigPos
    let lCurPos = lOrigPos

    if exists('g:lOCppScopeStack')
        let lScopeStack = g:lOCppScopeStack
    else
        let lScopeStack = omnicpp#scopes#GetScopeStack()
    endif
    " 从作用域栈顶部开始, 一直向上搜索块开始位置
    " 直至遇到非 'other' 类型的作用域,
    for dScope in reverse(lScopeStack)
        let lCurBlkStaPos = omnicpp#scopes#GetCurBlockStartPos(1)
        if lCurBlkStaPos == [0, 0]
            " 到达这里, 肯定有语法错误, 或者是全局作用域
            let lStopPos = [0, 0]
            break
        endif

        if dScope.kind != 'other'
            break
        endif
    endfor

    if lStopPos != [0, 0]
        let lStopPos = omnicpp#utils#GetCurStatementStartPos(1)
    endif

    if a:0 > 0 && a:1
    else
        call setpos('.', lOrigCursor)
    endif

    return lStopPos
endfunc
"}}}
" Search a local declaration
" Return: TypeInfo
" 搜索局部变量的声明类型. 
" TODO: 这个函数很慢! 需要优化. 需要变量分析的场合的速度比不需要的场合的慢 3 倍!
function! omnicpp#resolvers#SearchLocalDecl(sVariable) "{{{2
    let dTypeInfo = s:NewTypeInfo()
    let lOrigCursor = getpos('.')
    let lOrigPos = lOrigCursor[1:2]

    let bak_ic = &ignorecase
    set noignorecase

    " TODO: 这个函数比较慢
    let lStopPos = s:GetStopPosForLocalDeclSearch(0)
    let lCurPos = getpos('.')[1:2]
    while lCurPos != [0, 0]
        " 1. 往下搜索不超过起始位置的同名符号, 解析 tokens
        " 2. 若为无效的声明, 重复, 否则结束
        let lCurPos = searchpos('\C\<'. a:sVariable .'\>', 'Wb')

        " TODO: 这两个函数很慢. 禁用的话无法排除其他块中同名变量的干扰
        " 原因是, 前面或者后面嵌套的大括号太多, 想办法优化
        if 0
            if s:CmpPos(omnicpp#scopes#GetCurBlockStartPos(), lStopPos) > 0 
                        \&& s:CmpPos(omnicpp#scopes#GetCurBlockEndPos(), 
                        \            lOrigPos) < 0
                " 肯定进入了其他的 {} 块
                continue
            endif
        endif

        if lCurPos != [0, 0] && s:CmpPos(lCurPos, lStopPos) > 0
            " TODO: 验证是否有效的声明
            " 搜索 foo 声明行应该为 Foo foo;
            " TestCase:
            " mc.foo();
            " Foo foo;
            " foo;

            let lTokens = omnicpp#utils#TokenizeStatementBeforeCursor()

            " 上述情形, tokens 最后项的类型只能为
            " C++ 关键词或单词
            " * 或 & 后 > 操作符(eg. void *p; int &n; vector<int> x;)
            " TODO: 使用 tokens 检查
            " 若为操作符, 则只可以是 '&', '*', '>', ','
            " eg. std::map<int, int> a, &b, c, **d;
            " 预检查
            if !empty(lTokens)
                " 暂时的方案是, 判断最后的 token, 若为以下操作符, 必然不是声明
                " ., ->, (, =, -, +, &&, ||
                "if lTokens[-1].kind == 'cppOperatorPunctuator' 
                            "\&& lTokens[-1].value =~# 
                            "\   '\V.\|->\|(\|=\|-\|+\|&&\|||'
                if lTokens[-1].kind == 'cppOperatorPunctuator' 
                            \&& lTokens[-1].value !~# '\V&\|*\|>\|,'
                    " 无效的声明, 继续
                    continue
                endif
            else
                " tokens 为空, 无效声明, 跳过
                continue
            endif

            " 解析声明
            let dTypeInfo = omnicpp#utils#GetVariableType(lTokens, a:sVariable)
            if dTypeInfo.name !=# ''
                break
            endif
        else
            " 搜索失败
            break
        endif
    endwhile

    call setpos('.', lOrigCursor)
    let &ignorecase = bak_ic

    return dTypeInfo
endfunc
"}}}
" vim:fdm=marker:fen:expandtab:smarttab:fdl=1:
