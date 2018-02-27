[ -e $HOME/.zsh/exports       ] && source $HOME/.zsh/exports
[ -e $HOME/.zsh/options       ] && source $HOME/.zsh/options
[ -e $HOME/.zsh/aliases       ] && source $HOME/.zsh/aliases
[ -e $HOME/.zsh/colour        ] && source $HOME/.zsh/colour
[ -e $HOME/.zsh/prompt        ] && source $HOME/.zsh/prompt
[ -e $HOME/.zsh/bindings      ] && source $HOME/.zsh/bindings
[ -e $HOME/.zsh/completion    ] && source $HOME/.zsh/completion
[ -d $HOME/.zsh/plugins/      ] && for plugin in $HOME/.zsh/plugins/*(.)zsh; do
    source $plugin
done
[ -e $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
    source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

if ! hostname | grep "^verns-\|li380-170\|^G08FNST\|^BITD" > /dev/null 2>&1; then
    return # 不是我的机器
fi

export HOME="/sun"
export DEBEMAIL="s5unty@gmail.com"
export DEBFULLNAME="Vern Sun"
export TZ='Asia/Shanghai'

if [ `tty | grep -c pts` -eq 1 ]; then
    stty -ixon -ixoff # 关闭 C-Q, C-S 流控制
    export TERM="rxvt-256color"
    export LANG="zh_CN.UTF-8"
fi

if [[ -f $HOME/.zsh/dircolors ]] ; then   #自定义颜色
    eval $(dircolors -b $HOME/.zsh/dircolors)
fi

# vim: ft=zsh et
