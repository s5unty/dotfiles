[ -e $HOME/.zsh/exports       ] && source $HOME/.zsh/exports
[ -e $HOME/.zsh/options       ] && source $HOME/.zsh/options
[ -e $HOME/.zsh/aliases       ] && source $HOME/.zsh/aliases
[ -e $HOME/.zsh/colour        ] && source $HOME/.zsh/colour
[ -e $HOME/.zsh/prompt        ] && source $HOME/.zsh/prompt
[ -e $HOME/.zsh/bindings      ] && source $HOME/.zsh/bindings
[ -e $HOME/.zsh/completion    ] && source $HOME/.zsh/completion
[ -e $HOME/.zsh/plugins/*.zsh ] && source $HOME/.zsh/plugins/*.zsh

if ! hostname | grep "^verns-" > /dev/null 2>&1; then
    return # 不是我的机器
fi

export HOME="/sun"
export DEBEMAIL="s5unty@gmail.com"
export DEBFULLNAME="Vern Sun"
export TZ='Asia/Shanghai'

if [ `tty | grep -c pts` -eq 1 ]; then
    stty -ixon -ixoff # 关闭 C-Q, C-S 流控制
    export TERM="rxvt-unicode"
    export LANG="zh_CN.UTF-8"
fi

for i in $MAILDIR/(company|personal)(/); do
    mailpath[$#mailpath+1]="${i}?<(￣3￣)> You have new mail in ${i:t}"
done

if hostname | grep "worktop" > /dev/null 2>&1; then
## export http_proxy=http://10.167.129.20:8080 ## whitelist
export http_proxy=http://10.167.129.21:8080

zstyle ':completion:*' users vern root Administrator
zstyle ':completion:*' users-hosts \
    vern@du1abadd.org root@10.167.225.216 root@10.33.135.13 root@10.33.135.15
zstyle ':completion:*' users-hosts-ports \
    Administrator@10.33.135.10:7000 Administrator@10.33.135.10:7001
zstyle ':completion:*:(ping|ssh|scp|sftp|rsync):*' hosts \
    10.167.226.154 10.167.225.120 10.167.129.20 10.167.129.21 10.167.225.216 10.33.135.10 10.33.135.13 10.33.135.15
fi

if hostname | grep "desktop" > /dev/null 2>&1; then

fi

if hostname | grep "laptop" > /dev/null 2>&1; then

fi
