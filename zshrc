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
alias -g L="| $__LESS"
alias -g M="| $__LESS"
alias -g C="| xclip"
# }}}

# 普通别名 {{{
alias ..="cd .."
alias ..1="cd .."
alias ..2="cd ../.."
alias ..3="cd ../../.."
alias ..4="cd ../../../.."
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
alias vim="/usr/bin/vim '+set formatoptions+=mM' '+set textwidth=78'"
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
alias -s png=feh
alias -s PNG=feh
alias -s gif=feh
alias -s GIF=feh
alias -s jpg=feh
alias -s JPG=feh
alias -s bmp=feh
alias -s BMP=feh
alias -s xpm=feh
alias -s XPM=feh
alias -s jpeg=feh
alias -s JPEG=feh
alias -s icon=feh
alias -s ICON=feh
alias -s odt=ooffice -writer %U
alias -s doc=ooffice -writer %U
alias -s ods=ooffice -calc %U
alias -s xls=ooffice -calc %U
alias -s pdf=xpdf
alias -s txt=vim
alias -s conf=vim
alias -s html=firefox
alias -s chm=kchmviewer
alias -s planner=planner
# }}}

# 其它别名 {{{ 
cd() {
    if builtin cd "$@"; then
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
    grep -r $1 . ${(@)argv[2,$#]} L
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
export TERM="xterm"
export HOME="/sun/home"
export EDITOR="/usr/bin/vim"
export VISUAL="/usr/bin/vim"
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/bin/X11:/usr/games:."
export DEBEMAIL="s5unty@gmail.com"
export DEBFULLNAME="Vern Sun"
export JAVA_HOME="/usr/lib/jvm/java-1.5.0-sun-1.5.0.16/"
export CLASSPATH="$JAVA_HOME/lib/:."
export XDG_CONFIG_HOME="$HOME/.config"
## }}}

## 个性化提示符 {{{

# define colors {{{
autoload colors
if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
fi
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE GREY; do
    eval C_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
    eval C_L_$color='%{$fg[${(L)color}]%}'
done
C_OFF="%{$terminfo[sgr0]%}"
# }}}

# define prompt {{{
parse_git_branch() {
    echo "`git branch --no-color 2> /dev/null \
         | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'`"
}

set_prompt() {
    mypath="$C_OFF$C_L_MAGENTA%~"
    mygitb="$C_OFF$C_WHITE$(parse_git_branch)"
    myjobs=()
    for a (${(k)jobstates}) {
        j=$jobstates[$a];i="${${(@s,:,)j}[2]}"
        myjobs+=($a${i//[^+-]/})
    }
    myjobs=${(j:,:)myjobs}
    ((MAXMID=$COLUMNS / 2 - 2)) # truncate to this value
    RPS1="$RPSL$mypath$RPSR"
    rehash
}
RPSL=$'$C_OFF$C_GREY%$MAXMID<...<'
RPSR=$'$C_OFF$C_L_RED%(0?.$C_L_GREEN. (%?%))$mygitb$C_OFF'
RPS2='%^'
# }}}

case `tty` in
    /dev/pts/*)
        precmd()  {
            set_prompt
            print -Pn "\a\e]0;%n@$__IP:%l\a"
        }
        ;;
    /dev/tty*)
        precmd()  {
            set_prompt
        }
        ;;
    *)
        ;;
esac

PS1=$'$C_CYAN%(1j.[$myjobs]% $C_OFF .$C_OFF)%B%#%b '
## }}}

## 自动补全功能 {{{
autoload -U compinit
compinit

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

# sudo {{{
# http://blog.chinaunix.net/u1/39544/showart_1852988.html
zle -N sudo-command-line
bindkey "^s" sudo-command-line
sudo-command-line() {
    if [[ -z $BUFFER ]]; then
        zle up-history
    fi
    if [[ $BUFFER != sudo\ * ]]; then
        BUFFER="sudo $BUFFER"
    fi
    zle end-of-line
}
# }}}

# bc {{{
zle -N bc-command-line
bindkey "^b" bc-command-line
bc-command-line() {
    if [[ -z $BUFFER ]]; then
        zle up-history
    fi
    LBUFFER="echo \"scale=2;$BUFFER"
    RBUFFER="\" | bc"
}
# }}}

## }}}

## 快捷键绑定 {{{
bindkey '\eu'   undo
bindkey '\er'   history-incremental-search-backward
bindkey '\ea'   beginning-of-line
bindkey '\ee'   end-of-line
bindkey '\eb'   vi-backward-blank-word
bindkey '\ew'   vi-backward-kill-word
bindkey '\e '   complete-word
bindkey '\e;'   vi-cmd-mode
bindkey '\e\e'  vi-cmd-mode
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

# Load specific local stuff.
# (find-fline "~/.zshrc.local")
if [ -e ~/.zshrc.local   ]; then . ~/.zshrc.local; fi

## }}}

