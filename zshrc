source $HOME/.zsh/exports
source $HOME/.zsh/options
source $HOME/.zsh/aliases
source $HOME/.zsh/colour
source $HOME/.zsh/prompt
source $HOME/.zsh/bindings
source $HOME/.zsh/completion
source $HOME/.zsh/plugins/*.zsh

if [ m"verns-worktop" = m`hostname` ]; then # {{{1
export http_proxy=http://10.167.129.21:8080

zstyle ':completion:*' users vern root Administrator
zstyle ':completion:*' users-hosts \
    vern@du1abadd.org root@10.167.226.216 root@10.33.135.13 root@10.33.135.15
zstyle ':completion:*' users-hosts-ports \
    Administrator@10.33.135.10:7000 Administrator@10.33.135.10:7001
zstyle ':completion:*:(ping|ssh|scp|sftp|rsync):*' hosts \
    10.167.226.154 10.167.225.120 10.167.129.20 10.167.129.21 10.167.225.216 10.33.135.10 10.33.135.13 10.33.135.15
fi

if [ m"verns-desktop" = m`hostname` ]; then # {{{1

fi

if [ m"verns-laptop" = m`hostname` ]; then # {{{1

fi
