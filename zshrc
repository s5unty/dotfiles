source $HOME/.zsh/exports
source $HOME/.zsh/options
source $HOME/.zsh/aliases
source $HOME/.zsh/colour
source $HOME/.zsh/prompt
source $HOME/.zsh/bindings
source $HOME/.zsh/completion
source $HOME/.zsh/plugins/*.zsh

if ! hostname | grep "^verns-" > /dev/null 2>&1; then
    return # 不是我的机器
fi

export HOME="/sun"
export DEBEMAIL="s5unty@gmail.com"
export DEBFULLNAME="Vern Sun"
export TZ='Asia/Shanghai'

for i in $MAILDIR/(company|personal)(/); do
    mailpath[$#mailpath+1]="${i}?<(￣3￣)> You have new mail in ${i:t}"
done

if hostname | grep "worktop" > /dev/null 2>&1; then
export http_proxy=http://10.167.129.21:8080

# 已知两台代理：10.167.129.20 和 10.167.129.21
# 20 有白名单和下载限制
# 21 没有名单限制，可以下载超过 10M 的文件
# 重装系统时可以找 IT 临时开通

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
