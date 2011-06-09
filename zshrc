[ -e $HOME/.zsh/exports       ] && source $HOME/.zsh/exports
[ -e $HOME/.zsh/options       ] && source $HOME/.zsh/options
[ -e $HOME/.zsh/aliases       ] && source $HOME/.zsh/aliases
[ -e $HOME/.zsh/colour        ] && source $HOME/.zsh/colour
[ -e $HOME/.zsh/prompt        ] && source $HOME/.zsh/prompt
[ -e $HOME/.zsh/bindings      ] && source $HOME/.zsh/bindings
[ -e $HOME/.zsh/completion    ] && source $HOME/.zsh/completion
[ -e $HOME/.zsh/*.host        ] && source $HOME/.zsh/*.host
[ -e $HOME/.zsh/plugins/*.zsh ] && source $HOME/.zsh/plugins/*.zsh

if ! hostname | grep "^verns-\|vps6309259" > /dev/null 2>&1; then
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

if hostname | grep "^verns-" > /dev/null 2>&1; then
    for i in $MAILDIR/(company|personal)(/); do
        mailpath[$#mailpath+1]="${i}?<(￣3￣)> You have new mail in ${i:t}"
    done
fi

