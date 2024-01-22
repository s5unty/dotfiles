[ -e $HOME/.zsh/exports       ] && source $HOME/.zsh/exports
[ -e $HOME/.zsh/options       ] && source $HOME/.zsh/options
[ -e $HOME/.zsh/aliases       ] && source $HOME/.zsh/aliases
[ -e $HOME/.zsh/colour        ] && source $HOME/.zsh/colour
[ -e $HOME/.zsh/prompt        ] && source $HOME/.zsh/prompt
[ -e $HOME/.zsh/bindings      ] && source $HOME/.zsh/bindings
[ -e $HOME/.zsh/completion    ] && source $HOME/.zsh/completion

if ! hostname | grep "^verns-\|^wuans-\|li380-170\|^G08FNST\|^BITD" > /dev/null 2>&1; then
    return # 不是我的机器
fi

export HOME="/sun"
export DEBEMAIL="s5unty@gmail.com"
export DEBFULLNAME="Sun Wuan"
export TZ='Asia/Shanghai'
export TD="home"

if [ `tty | grep -c pts` -eq 1 ]; then
    stty -ixon -ixoff # 关闭 C-Q, C-S 流控制
    export TERM="xterm-kitty"
    export LANG="zh_CN.UTF-8"
fi

if [[ -f $HOME/.zsh/dircolors ]] ; then   #自定义颜色
    eval $(dircolors -b $HOME/.zsh/dircolors)
fi

# Zinit is a flexible and fast Zshell plugin manager that will allow you to install everything from GitHub and other sites {{{1
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# Multi-word, syntax highlighted history searching for Zsh {{{1
# https://github.com/zdharma/history-search-multi-word
zinit light robobenklein/zdharma-history-search-multi-word
zstyle ":history-search-multi-word" highlight-color "bg=default,bold"

# Fish-like autosuggestions for zsh {{{1
# https://github.com/zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-autosuggestions

# Fish shell like syntax highlighting for Zsh. {{{1
# https://github.com/zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)

# A cd command that learns - easily navigate directories from the command line {{{1
# https://github.com/wting/autojump
## python3 fucked up, switch to zsh-z
# zinit ice as"program" make"PREFIX=$ZPFX" src"bin/autojump.sh"
# zinit light wting/autojump
####

# Jump quickly to directories that you have visited "frecently." {{{1
# https://github.com/agkozak/zsh-z
zinit light agkozak/zsh-z

##
# NOTE urxvt => kitty
##
# # zsh-complete-words-from-urxvt-scrollback-buffer {{{1
# # https://gist.github.com/s5unty/2486566
# zinit snippet https://gist.github.com/s5unty/2486566/raw
# bindkey -M viins "\e\t" urxvt-scrollback-buffer-words-prefix    # Alt-Tab
# bindkey -M viins "^[[Z" urxvt-scrollback-buffer-words-anywhere  # Shift-Tab
####

# Magical shell history
# https://github.com/atuinsh/atuin {{{1
eval "$(atuin init zsh --disable-up-arrow)"


# >>> conda initialize >>> {{{1
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<}}}

