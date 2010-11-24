## 定义变量 {{{
if   [ -e "/usr/bin/zless" ]; then __LESS="zless -r"
elif [ -e "/usr/bin/less"  ]; then __LESS="less -r"
else __LESS="more" fi

if [ -e "/usr/bin/colordiff" ]; then __DIFF="colordiff" else __DIFF="diff" fi
if [ -e "/usr/bin/sudo" ];      then __SUDO="sudo" fi

__IP=`/sbin/ifconfig -v | grep 192.168.1 | tail -1 | cut -d'.' -f4 | cut -d' ' -f1`
## }}}

## 定义别名 {{{

# 全局别名 {{{
alias -g G="| grep"
alias -g M="| $__LESS"
alias -g Y="| xsel"
# }}}

# 普通别名 {{{
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
alias vim="/usr/bin/vim --noplugin"
alias tig="tig --all"
#alias make="/usr/bin/make -j2"
# }}}

# apt-get 别名 {{{
alias api="$__SUDO apt-get install"
alias apo="apt-get source"
alias ape="$__SUDO vi /etc/apt/sources.list"
alias apr="$__SUDO apt-get remove"
alias apu="$__SUDO apt-get update"
alias app="$__SUDO apt-get purge"
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

# task 别名 {{{
alias tda="task add"
alias tde="task edit"
alias tdu="task undo"
alias tdg="task long"
alias tdS="task info"
alias tds="task start"
alias tdr="task stop"
alias tdd="task done"
alias tdp="task delete"
alias tdi="task annotate"
alias tdL="task timesheet && task history.annual && task summary"
# }}}

# tar 别名 {{{
tgz() {
    name=`echo $1 | sed 's/\/*$//g'`
    tar -zcf "$name.tgz" $@
}
tgzz() {
    name=`echo $1 | sed 's/\/*$//g'`
    tar -zcf "$name.tgz" $@ --exclude=.cscope --exclude-vcs
}
tgx() { $__SUDO tar -zxvf $@ }
tgg() { tar -tf $@ }

tjz() {
    name=`echo $1 | sed 's/\/*$//g'`
    tar -jcf "$name.tbz" $@
}
tjzz() {
    name=`echo $1 | sed 's/\/*$//g'`
    tar -jcf "$name.tbz" $@ --exclude=.cscope --exclude-vcs
}
tjx() { $__SUDO tar -jxvf $@ }
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
alias -s pdf=FoxitReader
alias -s html=firefox
alias -s chm=kchmviewer
alias -s planner=planner
# }}}

# 目录别名 {{{
# unhash -dm '*'
zstyle ':completion:*:*:*:users' ignored-patterns _dhcp _pflogd adm apache \
	avahi avahi-autoipd backup bin bind clamav cupsys cyrusdaemon daemon \
	Debian-exim dictd dovecot games gnats gdm ftp halt haldaemon hplip ident \
	identd irc junkbust klog kmem libuuid list lp mail mailnull man \
	messagebus mysql munin named news nfsnobody nobody nscd ntp ntpd \
	operator pcap polkituser pop postfix postgres proftpd proxy pulse radvd \
	rpc rpcuser rpm saned shutdown smmsp spamd squid sshd statd stunnel sync \
	sys syslog toor tty uucp vcsa varnish vmail vde2-net www www-data xfs \
	bitlbee debian-tor minbif root usbmux canna fetchmail privoxy
# }}}

# 其它别名 {{{ 
cd() {
    if builtin cd "$@"; then
        ls
    fi
}

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
    find ./ -iname "*$1*" ${(@)argv[2,$#]}
}
R() { # find in files
    ack-grep -r $1 . ${(@)argv[2,$#]}
}
CS() { # gen cscope.files
    mkdir -p .cscope
    find . -iname '*.c' -o -iname '*.cpp' -o -iname '*.cc' -o -iname '*.cxx' \
        -o -iname '*.h' -o -iname '*.hpp' -o -iname '*.hh' -o -iname '*.hxx' \
        -o -iname '*.java' > .cscope/cscope.files
    cscope -kbq -i.cscope/cscope.files -f.cscope/cscope.out
    ctags --c++-kinds=+p --fields=-fst --extra=+q --tag-relative -L.cscope/cscope.files -f.cscope/cscope.tags
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
export TZ='Asia/Shanghai'
export HOME="/sun/home"
export EDITOR="/usr/bin/vim"
export VISUAL="/usr/bin/vim"
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/bin/X11:/usr/games:."
export DEBEMAIL="s5unty@gmail.com"
export DEBFULLNAME="Vern Sun"
export JAVA_HOME="/usr/lib/jvm/java-6-sun/"
export CLASSPATH=".:$JAVA_HOME/class/:$JAVA_HOME/lib/"
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
    myjobs=()
    for a (${(k)jobstates}) {
        j=$jobstates[$a];i="${${(@s,:,)j}[2]}"
        myjobs+=($a${i//[^+-]/})
    }
    myjobs="$at_none$fg_cyan%(1j/[${(j/,/)myjobs}] /)"
    mypath="$at_none$fg_green$at_italics%~"
    myerrs="$at_none$fg_lred%(0?.. (%?%))"
    mygitb="$at_none$fg_white$at_bold$(parse_git_branch)"
       PS1="$at_none$at_bold%!%#$at_none "
      RPS1="$myjobs$fg_green%$MAXMID<...<$mypath$myerrs$mygitb$at_none"
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

# ping|ssh|scp {{{
zstyle ':completion:*:(ping|ssh|scp|sftp):*' hosts \
    du1abadd.org \
    192.168.1.{1,2}
# }}}

zstyle ':completion:*' special-dirs true
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
    # <ESC>Ea
    zle vi-cmd-mode
    zle vi-forward-blank-word-end
    zle vi-add-next
}
zle -N _vi-forward-blank

_vi-backward-blank() {
    # <ESC>B
    zle vi-backward-blank-word
#    zle vi-backward-char
}
zle -N _vi-backward-blank

# what's ranger?
# http://ranger.nongnu.org/
# https://github.com/hut/ranger
ranger() {
  before="$(pwd)"
  python /usr/local/bin/ranger --fail-unless-cd "$@" || return 0
  after="$(grep \^\' ~/.config/ranger/bookmarks | cut -d':' -f2)"
  if [[ "$before" != "$after" ]]; then
    cd "$after"
  fi
}
bindkey -s '^o' 'ranger\r'
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

WORDCHARS='*?_-‘’[]~=&;!#$%^(){}<>'

zle_highlight=(region:bg=blue     #选中区域
               special:bold       #特殊字符
               isearch:underline) #搜索时使用的关键字

# 检查邮件 {{{
for i in /sun/mails/(company|personal)(/); do
    mailpath[$#mailpath+1]="${i}?You have new mail in ${i:t}."
done
# }}}

# Load specific local stuff.
# (find-fline "~/.zshrc.local")
if [ -e ~/.zshrc.local   ]; then . ~/.zshrc.local; fi

## }}}
