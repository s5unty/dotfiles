#!/bin/bash

export COLOR_CONTEXT="$AT_UNDERL"
export COLOR_PROJECT="$AT_BOLD"
export COLOR_ADD_ONS="$AT_ITALIC"

# Force gawk to behave posixly. Comment out if you get an error about
# no such option -W.
AWK_OPTIONS=""
if [ "$TODOTXT_PLAIN" -eq "0" ]; then
    # 1. gawk 格式化 REM 开头的内容 `man remind`，添加 (*) 标记
    # 2. eval 对添加了 (*) 标记的内容重新排序
    # 3. gawk 高亮关键字
    gawk $AWK_OPTIONS '
        function highlight(colorVar, color) {
            color = ENVIRON[colorVar]
            gsub(/\\+033/, "\033", color)
            return color
        }
        {
            IGNORECASE = 1
            $0=gensub(/ REM.*MSG[ ]+/, " (*) " highlight(color), "g", $0);
            print
        }
    ' \
    | eval ${TODOTXT_SORT_COMMAND} \
    | gawk $AWK_OPTIONS '
        function highlight(colorVar, color) {
            color = ENVIRON[colorVar]
            gsub(/\\+033/, "\033", color)
            return color
        }
        { color = "DEFAULT" }
        /\(A\)/ { color = "PRI_A" }
        /\(B\)/ { color = "PRI_B" }
        /\(C\)/ { color = "PRI_C" }
        /\(I\)/ { color = "PRI_I" }
        /\(F\)/ { color = "PRI_F" }
        {
            $0=gensub(/ (@\w*)/,                " " highlight("COLOR_CONTEXT")  "\\1" highlight(color), "g", $0);
            $0=gensub(/ (\+[[:alnum:]_\-/]*)/,  " " highlight("COLOR_PROJECT")  "\\1" highlight(color), "g", $0);
            $0=gensub(/ ([[:alnum:]_\-/@#]+:[[:alnum:]=.<>_\-/@#]+)/,
                                                " " highlight("COLOR_ADD_ONS")  "\\1" highlight(color), "g", $0);
            print
        }
    '
else
    cat
fi

