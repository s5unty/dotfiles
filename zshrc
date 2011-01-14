# VARS {{{1
export HISTFILE=~/.zsh_history
export HISTSIZE=409600
export SAVEHIST=409600
export DEBIAN_DIR=""
export REPREPRO_CONFIG_DIR=""
export LANG="zh_CN.UTF-8"
export TZ='Asia/Shanghai'
export HOME="/sun"
export EDITOR="/usr/bin/vim"
export VISUAL="/usr/bin/vim"
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/bin/X11:/usr/games:."
export DEBEMAIL="s5unty@gmail.com"
export DEBFULLNAME="Vern Sun"
export JAVA_HOME="/usr/lib/jvm/java-6-sun"
export CLASSPATH=".:$JAVA_HOME/class/:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar"
export XDG_CONFIG_HOME="$HOME/.config"
export DOTREMINDERS=~/.task/reminders
export PATH=$PATH:/var/lib/gems/1.8/bin/
export PATH=$PATH:~/vp10-android-2.1_r2/out/host/linux-x86/bin

# use the built in directory navigation via the directory stack {{{2
# http://zsh.sourceforge.net/Doc/Release/zsh_15.html
# keep a persistent dirstack in ~/.zsh_dirs, from Francisco Borges, on zsh.devel
DIRSTACKSIZE=10
if [[ -f ~/.zsh_dirs ]] && [[ ${#dirstack[*]} -eq 0 ]]; then
    dirstack=( ${(uf)"$(< ~/.zsh_dirs)"} )
    builtin cd $(head -1 ~/.zsh_dirs)
fi
chpwd() { dirs -pl | uniq >! ~/.zsh_dirs }

# turn off XON/XOFF, but only for a tty {{{2
tty > /dev/null && stty -ixon -ixoff

# don't ask me before menu selection {{{2
LISTPROMPT=''

# word delimiter characters in line editor {{{2
WORDCHARS='*?_-[]~=&:;!#$%^(){}<>'

# checks for new mail every 10 minutes {{{2
MAILCHECK=600
for i in /sun/maildir/(company|personal)(/); do
    mailpath[$#mailpath+1]="${i}?You have new mail in ${i:t}."
done
# {{{2
if   [ -e "/usr/bin/zless" ]; then __LESS="zless -r"
elif [ -e "/usr/bin/less"  ]; then __LESS="less -r"
else __LESS="more" fi

if [ -e "/usr/bin/colordiff" ]; then __DIFF="colordiff" else __DIFF="diff" fi
if [ -e "/usr/bin/sudo" ];      then __SUDO="sudo" fi

__IP=`/sbin/ifconfig -v | grep 192.168.1 | tail -1 | cut -d'.' -f4 | cut -d' ' -f1`

######################################################################## }}}1

# OPTIONS {{{1
autoload zsh/terminfo
autoload -U zed
autoload -U compinit && compinit
autoload -U insert-files && zle -N insert-files
autoload -U copy-earlier-word && zle -N copy-earlier-word
autoload -U edit-command-line && zle -N edit-command-line

zmodload -i zsh/complist
zmodload -i zsh/deltochar
zmodload -i zsh/mathfunc
zmodload -a zsh/stat stat
zmodload -a zsh/zpty zpty
zmodload -a zsh/zprof zprof
zmodload -a zsh/mapfile mapfile

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
setopt FLOW_CONTROL         # don't ignore ^S/^Q
setopt LONGLISTJOBS         # display PID when suspending processes as well
setopt NOTIFY               # report the status of backgrounds jobs immediately
setopt COMPLETEINWORD       # not just at the end

zle_highlight=(region:bg=blue     #选中区域
               special:bold       #特殊字符
               isearch:underline) #搜索时使用的关键字

eval $(dircolors -b ~/.dircolors) #自定义颜色
######################################################################## }}}1

# ALIAS {{{1
alias -g G='|GREP_COLOR=$(echo 3$[$(date +%N)%6+1]'\'';1;7'\'') egrep -i --color=always'
alias -g M="| $__LESS"
alias -g Y="| xsel"
alias -g iy="| xsel"
alias ds="dirs -v | head -30 | sort -nr"
alias cs="history 0"
alias ll="ls -hl"
alias la="ls -hlA"
alias ls="ls --color=always -F -h"
alias cp="cp -a"
alias rm="rm -r"
alias at="at -m"
alias diff="$__DIFF"
alias more="$__LESS"
alias tree="tree -C"
alias sudo="sudo env PATH=${PATH} env HOME=${HOME}"
alias scp="scp -p"
alias lintian="lintian -viI"
alias vi="/usr/bin/vim -n"
alias vim="/usr/bin/vim --noplugin"
alias tig="tig --all"

# apt-get {{{2
alias api="$__SUDO apt-get install"
alias apo="apt-get source"
alias ape="$__SUDO vi /etc/apt/sources.list"
alias apr="$__SUDO apt-get remove"
alias apu="$__SUDO apt-get update"
alias app="$__SUDO apt-get purge"
alias apg="apt-cache search"
alias aps="apt-cache show"
alias apv="apt-cache policy"

# dpkg {{{2
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

# task {{{2
alias td="task summary && print && task history && rem"
alias tda="task add"
alias tde="task edit"
alias tdu="task undo"
alias tdg="task ls"
alias tdl="task long"
alias tdc="task info"
alias tdi="task annotate"
alias tdS="task start"
alias tdP="task stop"
alias tdD="task done"
alias tdR="task delete"
tds() {
    task start ${1}
    DESC=`task info ${1} | grep ^Desc | cut -b13-`
    UUID=`task info ${1} | grep ^UUID | cut -b13-`
    REM=`date -d"today" +"REM AT 23:30 +900 *15 TAG ${UUID} MSG ${DESC}"`
    echo ${REM} >> ~/.task/reminders
}
tdp() {
    task stop ${1}
    UUID=`task info ${1} | grep ^UUID | cut -b13-`
    sed -i '/'${UUID}'/d' ~/.task/reminders
}
tdd() {
    task done ${1}
    UUID=`task info ${1} | grep ^UUID | cut -b13-`
    sed -i '/'${UUID}'/d' ~/.task/reminders
}
tdr() {
    task delete ${1}
    UUID=`task info ${1} | grep ^UUID | cut -b13-`
    sed -i '/'${UUID}'/d' ~/.task/reminders
}

# tar {{{2
tgz() {
    name=`echo $1 | sed 's/\/*$//g'`
    tar -zcf "$name.tgz" $@
}
tgzz() {
    name=`echo $1 | sed 's/\/*$//g'`
    tar -zcf "$name.tgz" $@ --exclude=.cscope --exclude-vcs
}
tgx() {
    $__SUDO tar -zxvf $@
}
tgg() {
    tar -tf $@
}

tjz() {
    name=`echo $1 | sed 's/\/*$//g'`
    tar -jcf "$name.tbz" $@
}
tjzz() {
    name=`echo $1 | sed 's/\/*$//g'`
    tar -jcf "$name.tbz" $@ --exclude=.cscope --exclude-vcs
}
tjx() {
    $__SUDO tar -jxvf $@
}
tjg() {
    tar -tf $@
}

# file {{{2
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

# fold {{{2
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

# OTHERS {{{2
cd() {
    if builtin cd "$@"; then
        ls
    fi
}

md() {
    mkdir $*
    cd $1
}

tcp() {
    tar cpf - ${(@)argv[1, -2]} | tar xvf - -C ${argv[-1]}
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

/() { # find
    find ./ -iname "*$1*" ${(@)argv[2,$#]}
}

R() { # find in files
    export GREP_COLOR=$(echo 3$[$(date +%N)%6+1]';1;7')
    egrep -ri --color=always \
        --exclude="*.old" --exclude="*.bak" --exclude="*.BAK" --exclude="*.orig" \
        --exclude="*.rej" --exclude="*.a" --exclude="*.olb" --exclude="*.o" \
        --exclude="*.obj" --exclude="*.so" --exclude="*.exe" --exclude="*.gz" \
        --exclude="*.tar" --exclude="*.zip" --exclude="*.tgz" --exclude="*.bz2" \
        --exclude="*.deb" --exclude="*.jar" --exclude="*.cab" --exclude="*.tbz" \
        --exclude="*.jpg" --exclude="*.jpeg" --exclude="*.png" --exclude="*.gif" \
        --exclude="*.pdf" --exclude-dir=".cscope" --exclude-dir=".svn" --exclude-dir=".git" \
        "$*" .
}

CS() { # gen cscope.files
    mkdir -p .cscope
    find . -iname '*.c' -o -iname '*.cpp' -o -iname '*.cc' -o -iname '*.cxx' \
        -o -iname '*.h' -o -iname '*.hpp' -o -iname '*.hh' -o -iname '*.hxx' \
        -o -iname '*.java' > .cscope/cscope.files
    cscope -kbq -i.cscope/cscope.files -f.cscope/cscope.out
    ctags --c++-kinds=+p --fields=-fst --extra=+q --tag-relative -L.cscope/cscope.files -f.cscope/cscope.tags
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

######################################################################## }}}1

# PROMPT {{{1
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
    mygitb="$at_none$fg_white$(parse_git_branch)"
       PS1="$at_none$fg_lgray%!%#$at_none "
      RPS1="$myjobs$fg_green%$MAXMID<...<$mypath$myerrs$mygitb$at_none"
    rehash
}

case `tty` in
    /dev/pts/*)
        export TERM="rxvt-unicode"
        precmd() { set_prompt; print -Pn "\a\e]0;%n@$__IP:%l\a" }
        ;;
    *)
        export TERM="xterm"
        export LANG="C"
        precmd() { set_prompt; }
        ;;
esac

# colours and attributes {{{2
# Text Foreground Colors {{{3
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
# Text Background Colors {{{3
bg_red=$'%{\e[0;41m%}'
bg_green=$'%{\e[0;42m%}'
bg_brown=$'%{\e[0;43m%}'
bg_blue=$'%{\e[0;44m%}'
bg_purple=$'%{\e[0;45m%}'
bg_cyan=$'%{\e[0;46m%}'
bg_gray=$'%{\e[0;47m%}'
# Attributes {{{3
at_none="%{$terminfo[sgr0]%}"
at_bold=$'%{\e[1m%}'
at_italics=$'%{\e[3m%}'
at_underl=$'%{\e[4m%}'
at_blink=$'%{\e[5m%}'
at_reverse=$'%{\e[7m%}'

# Git function {{{3 
parse_git_branch() {
    branch="$(git branch --no-color 2> /dev/null | \
        sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"

    git diff --no-ext-diff --quiet 2> /dev/null
    flag=$?
    if [ $flag -eq 1 ]; then # branch is not clear
        _branch=" ${at_underl}${branch}"
    elif [ $flag -eq 0 ]; then # branch is clear
        _branch=" ${branch}"
    else # there is not git repository == 129
        _branch=""
    fi

    stash="$(git stash list 2> /dev/null | \
        grep -q "${branch}")"
    if [ $? -eq 0 ]; then # branch has stash
        _stash="${at_none} ${fg_purple}${at_blink}WIP"
    else
        _stash=""
    fi

    echo "${_branch}${_stash}"
}

######################################################################## }}}1

# COMPLETAION {{{1
zstyle ':completion:*' menu select
zstyle ':completion:*' expand true
zstyle ':completion:*' file-sort name
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ${fg_lred}${at_italics}'%d (%e errors)'${at_none}
zstyle ':completion:*:descriptions' format ${fg_lgreen}${at_italics}'%d'${at_none}
zstyle ':completion:*:messages' format ${fg_lgreen}${at_italics}'%d'${at_none}
zstyle ':completion:*:warnings' format ${fg_white}${at_italics}'No matches for: %d'${at_none}

# cd - {{{2
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select

# correct {{{2
zstyle ':completion:::::' completer _complete _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# caching {{{2
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path .zcache

# kill {{{2
compdef pkill=killall
zstyle ':completion:*:processes' command 'ps --forest -au$USER -o pid,time,cmd|grep -v "ps -au$USER -o pid,time,cmd"'
zstyle ':completion:*:processes' list-colors '=(#b) #([0-9]#)[ 0-9:]#([^ ]#)*=01;30=01;31=01;38'
zstyle ':completion:*:processes-names' command 'ps -au$USER -o comm|grep -v "ps -au$USER -o comm"'

# ping|ssh|scp {{{2
zstyle ':completion:*:(ping|ssh|scp|sftp):*' hosts \
    du1abadd.org \
    192.168.{1,2}.{1,2}
zstyle ':completion:*' special-dirs true

######################################################################## }}}1

# KEY BINDINGS {{{1

bindkey '^n'    history-search-forward
bindkey '^p'    history-search-backward
bindkey "^[e"   edit-command-line          # ALT-E
bindkey "^[h"   backward-char              # ALT-H
bindkey "^[l"   forward-char               # ALT-H
bindkey "^[b"   vi-backward-blank-word     # ALT-B
bindkey "^[f"   _vi-forward-blank          # ALT-F
bindkey "^[x"   delete-char                # ALT-X
bindkey "^[,"   copy-earlier-word          # ALT-,
bindkey "\t"    expand-or-complete
bindkey " "     magic-space                # ' ' (Space)

bindkey -s            "^q"  "run-ranger\r"
bindkey -M menuselect "i"   accept-and-menu-complete
bindkey -M menuselect "^o"  accept-and-infer-next-history

bindkey "$terminfo[kf1]"    run-help       # F1
bindkey "$terminfo[kf2]"    which-command  # F2
bindkey "$terminfo[kf11]"   run-netstat    # F11
bindkey "$terminfo[kf12]"   run-ps         # F12

# functions {{{2
insert-last-typed-word() {
    zle insert-last-word -- 0 -1
}
zle -N insert-last-typed-word

_vi-forward-blank() {
    # <ESC>Ea
    zle vi-cmd-mode
    zle vi-forward-blank-word-end
    zle vi-add-next
}
zle -N _vi-forward-blank

# what's ranger?
# http://ranger.nongnu.org/
# https://github.com/hut/ranger
run-ranger() {
    before="$(pwd)"
    ranger --fail-unless-cd "$@" || return 0
    after="$(grep \^\' ~/.config/ranger/bookmarks | cut -d':' -f2)"
    if [[ "$before" != "$after" ]]; then
        cd "$after"
    fi
}

run-ps () {
    zle -I
    ps x --forest -u$USER -wwwA -o pid,user,cmd | less
}
zle -N run-ps

run-netstat () {
    zle -I
    netstat -ltupn
}
zle -N run-netstat

# jump behind the first word on the cmdline.
# useful to add options.
# TODO jump_arg2, arg3 ...
jump_arg1 () {
    local words
    words=(${(z)BUFFER})

    if (( ${#words} <= 1 )) ; then
        CURSOR=${#BUFFER}
    else
        CURSOR=${#${words[1]}}
    fi
}
zle -N jump_arg1

######################################################################## }}}1

# Load specific stuff {{{1
if [ s`hostname` = s"verns-worktop" ]; then
    . /usr/local/poky/eabi-glibc/arm/environment-setup
    alias -g XX='--host=arm-poky-linux-gnueabi'
fi

if [ s`hostname` = s"verns-desktop" ]; then

fi

if [ s`hostname` = s"verns-laptop" ]; then

fi
