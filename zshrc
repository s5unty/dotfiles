## 定义变量 {{{
if   [ -e "/usr/bin/zless" ]; then __LESS="zless -r"
elif [ -e "/usr/bin/less"  ]; then __LESS="less -r"
else __LESS="more" fi

if [ -e "/usr/bin/X11/colordiff" ]; then __DIFF="colordiff" else __DIFF="diff" fi
if [ -e "/usr/bin/sudo" ];          then __SUDO="sudo" fi

__IP=`/sbin/ifconfig -v | grep 192.168.1 | tail -1 | cut -d'.' -f4 | cut -d' ' -f1`
## }}}

## 定义别名 {{{

# 全局别名 {{{
alias -g G="| grep"
alias -g M="| $__LESS"
# }}}

# 普通别名 {{{
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ds="dirs -v | head -30 | sort -nr"
alias cs="history 0"
alias ll="ls -hl"
alias la="ls -hlA"
alias ls="ls --color=always -F -h"
alias cp="cp -a"
alias rm="rm -r"
alias at="at -m"
alias gh="ditz html ~/issues/html/"
alias grep="grep --color=always"
alias diff="$__DIFF"
alias more="$__LESS"
alias tree="tree -C"
alias scp="scp -p"
alias lintian="lintian -viI"
alias vi="/usr/bin/vim -n"
#alias make="/usr/bin/make -j2"
# }}}

# apt-get 别名 {{{
alias api="$__SUDO apt-get install"
alias apo="$__SUDO apt-get source"
alias ape="$__SUDO vi /etc/apt/sources.list"
alias apr="$__SUDO apt-get remove"
alias apu="$__SUDO apt-get update"
alias apg="apt-cache search"
alias aps="apt-cache show"
alias apv="apt-cache policy"
# }}}

# dpkg 别名 {{{
alias dpi="$__SUDO dpkg -i"
alias dpp="$__SUDO dpkg -P"
alias dpc="dpkg -c"
alias dps="dpkg -I"
alias dpo="dpkg -e"
alias dpx="dpkg -x"
alias dpg="dpkg -l | grep"
alias dpG="dpkg -S"
alias dpL="dpkg -L"
dpH() { echo "$1 hold" | $__SUDO dpkg --set-selections }
dpI() { echo "$1 install" | $__SUDO dpkg --set-selections }
# }}}

# devtodo 别名 {{{
alias tdD="devtodo -D"
alias tdR="devtodo -R"
alias tdG="devtodo -c"
alias tdS="devtodo -Av"
alias tda="cat - | todo -a"
tdg() {
    if [ -z "$1" ]; then
        devtodo
    # tdg [数字[.数字]]: 显示该条记录
    elif expr "$1" : "^[0-9\.]*$" > /dev/null 2>&1; then
        devtodo -c "$1"
    # tdg [字符串]: 查找对应记录
    else
        devtodo -A /"$1"
    fi
}

tds() {
    if [ -z "$1" ]; then
        devtodo -A
    # tdg [数字[.数字]]: 显示该条记录
    elif expr "$1" : "^[0-9\.]*$" > /dev/null 2>&1; then
        devtodo -cv "$1"
    # tdg [字符串]: 查找对应记录
    else
        devtodo -Av /"$1"
    fi
}
# }}}

# tar 别名 {{{
tgz() {
    name=`echo $1 | sed 's/\/*$//g'`
    tar -zcf "$name.tar.gz" $@
}
tgx() { tar -zxf $@ }
tgg() { tar -tf $@ }

tjz() {
    name=`echo $1 | sed 's/\/*$//g'`
    tar -jcf "$name.tar.bz2" $@
}
tjx() { tar -jxf $@ }
tjg() { tar -tf $@ }
# }}}

# 文件类型别名 {{{
alias -s png="qiv -p"
alias -s PNG="qiv -p"
alias -s gif="qiv -p"
alias -s GIF="qiv -p"
alias -s jpg="qiv -p"
alias -s JPG="qiv -p"
alias -s bmp="qiv -p"
alias -s BMP="qiv -p"
alias -s xpm="qiv -p"
alias -s XPM="qiv -p"
alias -s jpeg="qiv -p"
alias -s JPEG="qiv -p"
alias -s icon="qiv -p"
alias -s ICON="qiv -p"
alias -s odt="ooffice -writer"
alias -s doc="ooffice -writer"
alias -s ods="ooffice -calc"
alias -s xls="ooffice -calc"
alias -s pdf=foxitreader
alias -s html=firefox
alias -s chm=kchmviewer
alias -s planner=planner
# }}}

# 目录别名 {{{
unhash -dm '*'
hash -d log="/var/log/"
hash -d net="/etc/network/"
hash -d inc="/usr/include/"
hash -d rcS="/etc/init.d/"
# }}}

# 其它别名 {{{ 
cd() {
    if builtin cd "$@"; then
        todo
        ls
    fi
}
if [ -f `which todo` ]; then todo; fi

T() { # tail
    if [ -r $*[$#] ]; then
        tail $*
    else
        $__SUDO tail $*
    fi
}
K() { # kill
    killall -u $USER $1
}
P() { # ps
    ps -ef | grep "$1" | grep -v "grep"
}
F() { # find
    find ./ -iname "$1" ${(@)argv[2,$#]}
}
R() { # find in files
    grep -r $1 . ${(@)argv[2,$#]} M
}
C() { # gen cscope.files
    mkdir .cscope
    find . -iname '*.c' -o -iname '*.cpp' -o -iname '*.cc' \
        -o -iname '*.h' -o -iname '*.hpp' -o -iname '*.hh' > .cscope/cscope.files
    cscope -kbq -i.cscope/cscope.files -f.cscope/cscope.out
    ctags -u --c++-kinds=+p --fields=+ialS --extra=+q --tag-relative -L.cscope/cscope.files -f.cscope/cscope.tags
}
O() { # chown
	$__SUDO chown -R s5unty:s5unty $*
}

dup() { # dupload
    if echo "$1" | grep -q '\.changes$' ; then
        # dup *.changes
        /usr/bin/dupload $@
    else
        # dup 127 *.changes
        /usr/bin/dupload -t "$1" ${(@)argv[2,$#]}
    fi
}
# }}}

## }}}

## 导出环境变量 {{{
export HISTFILE=~/.zsh_history
export HISTSIZE=409600
export SAVEHIST=409600
export DEBIAN_DIR=""
export REPREPRO_CONFIG_DIR=""
export LANG="zh_CN.UTF-8"
export TZ='UTC-8'
export HOME="/sun/home"
export EDITOR="/usr/bin/vim"
export VISUAL="/usr/bin/vim"
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/bin/X11:/usr/games:."
export DEBEMAIL="s5unty@gmail.com"
export DEBFULLNAME="Vern Sun"
export JAVA_HOME="/usr/lib/jvm/java-6-sun/"
export CLASSPATH=".:$JAVA_HOME/class/:$JAVA_HOME/lib/:/opt/android-sdk/platforms/android-2.0.1/android.jar"
export XDG_CONFIG_HOME="$HOME/.config"
## }}}

## 个性化提示符 {{{

# define colours {{{
#Text Foreground Colors
fg_black=$'%{\e[0;30m%}'
fg_red=$'%{\e[0;31m%}'
fg_green=$'%{\e[0;32m%}'
fg_brown=$'%{\e[0;33m%}'
fg_blue=$'%{\e[0;34m%}'
fg_purple=$'%{\e[0;35m%}'
fg_cyan=$'%{\e[0;36m%}'
fg_lgray=$'%{\e[0;37m%}'
fg_dgray=$'%{\e[1;30m%}'
fg_lred=$'%{\e[1;31m%}'
fg_lgreen=$'%{\e[1;32m%}'
fg_yellow=$'%{\e[1;33m%}'
fg_lblue=$'%{\e[1;34m%}'
fg_pink=$'%{\e[1;35m%}'
fg_lcyan=$'%{\e[1;36m%}'
fg_white=$'%{\e[1;37m%}'
#Text Background Colors
bg_red=$'%{\e[0;41m%}'
bg_green=$'%{\e[0;42m%}'
bg_brown=$'%{\e[0;43m%}'
bg_blue=$'%{\e[0;44m%}'
bg_purple=$'%{\e[0;45m%}'
bg_cyan=$'%{\e[0;46m%}'
bg_gray=$'%{\e[0;47m%}'
#Attributes
at_none="%{$terminfo[sgr0]%}"
at_bold=$'%{\e[1m%}'
at_italics=$'%{\e[3m%}'
at_underl=$'%{\e[4m%}'
at_blink=$'%{\e[5m%}'
at_reverse=$'%{\e[7m%}'
# }}}

# define prompt {{{
parse_git_branch() {
    git diff --quiet 2> /dev/null
    if [ $? -eq 1 ]; then # branch is not clear
        echo -n " $at_underl"
        echo "`git branch --no-color 2> /dev/null | \
        sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`"
        # |master|                       | no space here
    else
        echo "`git branch --no-color 2> /dev/null | \
        sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'`"
        # | master|                      | space here
    fi
}

set_prompt() {
    MAXMID="$(($COLUMNS / 2 - 5))" # truncate to this value
    mypath="$at_none$fg_green$at_italics%~"
    myerrs="$at_none$fg_lred%(0?.. (%?%))"
    mygitb="$at_none$fg_white$at_bold$(parse_git_branch)"
    myjobs=()
    for a (${(k)jobstates}) {
        j=$jobstates[$a];i="${${(@s,:,)j}[2]}"
        myjobs+=($a${i//[^+-]/})
    }
    myjobs="%(1j/[${(j/,/)myjobs}] /)"
     PS1="$fg_cyan$myjobs$at_none$at_bold%!%#$at_none "
    RPS1="$fg_green%$MAXMID<...<$mypath$myerrs$mygitb$at_none"
    rehash
}

case `tty` in
    /dev/pts/*)
        export TERM="rxvt-unicode"
        precmd() { set_prompt; print -Pn "\a\e]0;%n@$__IP:%l\a" }
        ;;
    /dev/tty*)
        export TERM="xterm"
        precmd() { set_prompt; }
        ;;
esac
## }}}

# }}}

## 自动补全功能 {{{
autoload -U compinit
compinit

# highlight {{{
zstyle ':completion:*' menu select
# }}}

# correct {{{
zstyle ':completion:::::' completer _complete _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric
# }}}

# caching {{{
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path .zcache
# }}}

# kill {{{
compdef pkill=kill
compdef pkill=killall
zstyle ':completion:*:*:kill:*' menu select
zstyle ':completion:*:processes' command 'ps -au$USER'
# }}}

# ping&ssh {{{
zstyle ':completion:*:ping:*' hosts 202.102.24.35 google.com \
       192.168.1.{{1..4},{100..103}}
zstyle ':completion:*:ssh:*' hosts \
       192.168.1.{{1..4},{100..103}}
zstyle ':completion:*:scp:*' hosts \
       192.168.1.{{1..4},{100..103}}
# }}}

## }}}

## 快捷键绑定 {{{
bindkey '\e;'   vi-cmd-mode
bindkey '\e'    vi-cmd-mode
bindkey '^l'    vi-forward-char
bindkey '^f'    _vi-forward-blank
bindkey '^b'    _vi-backward-blank
bindkey '^d'    delete-word
bindkey '^u'    undo
bindkey '^h'    vi-backward-char
bindkey '^j'    down-line-or-search
bindkey '^k'    up-line-or-search
bindkey '^n'    history-search-forward
bindkey '^p'    history-search-backward
bindkey '\e2'   quote-region

_vi-forward-blank() {
    # <ESC>ea
    zle vi-cmd-mode
    zle vi-forward-blank-word-end
    zle vi-add-next
}
zle -N _vi-forward-blank

_vi-backward-blank() {
    # <ESC>bh
    zle vi-backward-blank-word
    zle vi-backward-char
}
zle -N _vi-backward-blank
## mark #
# if [[ -z $BUFFER ]]; then
#     zle up-history
# fi
# LBUFFER="echo \"scale=2;$BUFFER"
# RBUFFER="\" | bc"
########

## }}}

## 杂七杂八选项 {{{
setopt AUTO_PUSHD
setopt AUTO_CD
setopt CDABLE_VARS
setopt PROMPT_SUBST
setopt PUSHD_MINUS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME
setopt PUSHD_IGNOREDUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY

# Umask of 022
umask 022

# use the built in directory navigation via the directory stack
# http://zsh.sourceforge.net/Doc/Release/zsh_15.html
# keep a persistent dirstack in ~/.zsh_dirs, from Francisco Borges, on zsh.devel
DIRSTACKSIZE=20
if [[ -f ~/.zsh_dirs ]] && [[ ${#dirstack[*]} -eq 0 ]]; then
	dirstack=( ${(uf)"$(< ~/.zsh_dirs)"} )
fi
chpwd() { dirs -pl >! ~/.zsh_dirs }

# turn off XON/XOFF, but only for a tty
tty > /dev/null && stty -ixon -ixoff

# terminfo module
autoload zsh/terminfo

# don't ask me 'do you wish to see all XX possibilities' before menu selection
LISTPROMPT=''

WORDCHARS='*?_-[]~=&;!#$%^(){}<>'

zle_highlight=(region:bg=blue     #选中区域
               special:bold       #特殊字符
               isearch:underline) #搜索时使用的关键字

# 检查邮件 {{{
for i in /sun/mails/(company|personal|debian-zh)(/); do
    mailpath[$#mailpath+1]="${i}?You have new mail in ${i:t}."
done
# }}}

# Load specific local stuff.
# (find-fline "~/.zshrc.local")
if [ -e ~/.zshrc.local   ]; then . ~/.zshrc.local; fi

## }}}

