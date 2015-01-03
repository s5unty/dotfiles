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

echo "$(date) ${form}: ${desc}" >> /tmp/pushbullet.log

# 在 https://www.pushbullet.com/account 得到 ${YOUR_API_TOKEN}
# 注意 ${YOUR_API_TOKEN} 的最后，要额外添加一个半角英文冒号
curl \
    -u ${YOUR_API_TOKEN}: \
    -X POST https://api.pushbullet.com/v2/pushes \
    --header 'Content-Type: application/json' \
    --data-binary "{\"type\": \"note\", \"title\": \"${form}\", \"body\": \"${desc}\"}" >> /tmp/pushbullet.log

echo "" >> /tmp/pushbullet.log
exit 0
