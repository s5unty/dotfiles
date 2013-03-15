#!/bin/zsh

message=$*
form=${message%%:*}
desc=${message#*: }

form=$(echo ${form} | sed \
    -e 's/ minutes\?/分钟/' \
    -e 's/ hours\?\( and \)\?/小时/' \
    -e 's/ from now/后/' \
    -e 's/ ago/前/g' \
    -e 's/^now/现在/' \
    -e 's/today/今天/' \
    -e 's/tomorrow/明天/' \
    -e 's/at \([0-9]\{1,2\}:[0-9]\{1,2\}[ap]m\)/\1/' \
    -e 's/in \([0-9]*\) days. time/\1天后/')

# 在 pushover.net 申请 App 后得到 ${YOUR_API_TOKEN}
# 在 pushover.net 注册用户后得到 ${YOUR_USER_KEY}
curl -s \
    --form-string "token=${YOUR_API_TOKEN}" \
    --form-string "user=${YOUR_USER_KEY}" \
    --form-string "title=${form}" \
    --form-string "message=${desc}" \
    https://api.pushover.net/1/messages.json >> /tmp/pushover.log

echo "" >> /tmp/pushover.log
exit 0
