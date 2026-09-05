[ -e $HOME/.zsh/exports       ] && source $HOME/.zsh/exports
[ -e $HOME/.zsh/options       ] && source $HOME/.zsh/options
[ -e $HOME/.zsh/aliases       ] && source $HOME/.zsh/aliases
[ -e $HOME/.zsh/colour        ] && source $HOME/.zsh/colour
[ -e $HOME/.zsh/bindings      ] && source $HOME/.zsh/bindings
[ -e $HOME/.zsh/completion    ] && source $HOME/.zsh/completion
[ -e $HOME/.zsh/local.host    ] && source $HOME/.zsh/local.host

if ! hostname | grep "^verns-\|^wuans-\|li380-170\|^G08FNST\|^BITD" > /dev/null 2>&1; then
    return # 不是我的机器
fi

export HOME="/sun"
export DEBEMAIL="s5unty@gmail.com"
export DEBFULLNAME="Sun Wuan"
export TZ='Asia/Shanghai'
export TD="work"

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
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
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

# A smarter cd command. Supports all major shells. {{{1
# https://github.com/ajeetdsouza/zoxide
eval "$(zoxide init zsh)"

##
# NOTE urxvt => kitty
##
# # zsh-complete-words-from-urxvt-scrollback-buffer {{{1
# # https://gist.github.com/s5unty/2486566
# zinit snippet https://gist.github.com/s5unty/2486566/raw
# bindkey -M viins "\e\t" urxvt-scrollback-buffer-words-prefix    # Alt-Tab
# bindkey -M viins "^[[Z" urxvt-scrollback-buffer-words-anywhere  # Shift-Tab
####

# Magical shell history {{{1
# https://github.com/atuinsh/atuin
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh --disable-up-arrow)"
##
# 目录权限、以及kitty的shell集成都有问题
##
# eval "$(atuin hex init zsh)"
####


# complete path name based upon the pinyin acronym of Chinese characters {{{1
# https://github.com/petronny/pinyin-completion
# zinit load petronny/pinyin-completion
# . /sun/.local/share/zinit/plugins/petronny---pinyin-completion/pinyin-completion.plugin.zsh
# . /sun/hacking/pinyin-completion/pinyin-completion.plugin.zsh

# The minimal, blazing-fast, and infinitely customizable prompt for any shell! {{{1
# https://starship.rs/
[ -e $(which starship) ] && eval "$(starship init zsh)" || source $HOME/.zsh/prompt


# rust
. "$HOME/.cargo/env"


# fnm
FNM_PATH="/sun/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi


# pnpm
export PNPM_HOME="/sun/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

