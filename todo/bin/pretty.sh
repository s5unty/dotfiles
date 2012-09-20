#!/bin/bash

export COLOR_CONTEXT="$AT_ITALIC"
export COLOR_PROJECT="$AT_BOLD"
export COLOR_ADD_ONS="$AT_UNDERL"

# Force gawk to behave posixly. Comment out if you get an error about
# no such option -W.
AWK_OPTIONS=""
if [ "$TODOTXT_PLAIN" -eq "0" ]; then
    # 1. gawk 格式化 REM 开头的内容 `man remind`，添加 (*) 标记
    #         格式化 x 开头的 done，添加 (x) 标记
    # 2. eval 对添加了 (*) 和 (x) 标记的内容重新排序
    # 3. gawk 高亮关键字
    gawk $AWK_OPTIONS '
        function highlight(colorVar, color) {
            color = ENVIRON[colorVar]
            gsub(/\\+033/, "\033", color)
            return color
        }
        { color = "RED" }
        {
            IGNORECASE = 1
            $0=gensub(/^([0-9]+) REM.*MSG[ ]+(.*)/, highlight(color)  "\\1 (S) \\2" highlight("AT_NONE"), "g", $0);
            $0=gensub(/ x /,           " (X) ", "g", $0);
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
        { color = "AT_NONE" }
        /\(A\)/ { color = "PRI_A" }
        /\(B\)/ { color = "PRI_B" }
        /\(C\)/ { color = "PRI_C" }
        /\(F\)/ { color = "PRI_F" }
        /\(I\)/ { color = "PRI_I" }
        /\(S\)/ { color = "RED" }
        /\(X\)/ { color = "COLOR_DONE" }
        {
            IGNORECASE = 1
            $0=gensub(/ \/\/ (.*$)/,            " " highlight("AT_REVERSE")     "\\1" highlight(color), "g", $0);
            $0=gensub(/ (@\w*)/,                " " highlight("COLOR_CONTEXT")  "\\1" highlight(color), "g", $0);
            $0=gensub(/ (\+[[:alnum:]_\-/]*)/,  " " highlight("COLOR_PROJECT")  "\\1" highlight(color), "g", $0);
            $0=gensub(/ (message-id:[[:alnum:]=.<>_\-/@#]+)/,
                                                " " highlight("COLOR_ADD_ONS")  "mutt" highlight(color), "g", $0);
            $0=gensub(/ ([[:alnum:]_\-/@#]+:[[:alnum:]=.<>_\-/@#]+)/,
                                                " " highlight("COLOR_ADD_ONS")  "\\1" highlight(color), "g", $0);
            print
        }
    '
else
    cat
fi

