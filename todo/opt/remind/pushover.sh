#!/bin/sh

form=$1; shift
form=$(echo $form | \
    sed -e 's/ and //' | \
    sed -e 's/ minutes/分钟/' | \
    sed -e 's/ hours/小时/' | \
    sed -e 's/ from now/后/g' | \
    sed -e 's/ ago/前/g' | \
    sed -e 's/^now/现在/')

# 在 pushover.net 申请 App 后得到 ${YOUR_API_TOKEN}
# 在 pushover.net 注册用户后得到 ${YOUR_USER_KEY}
desc=$*
curl -s \
    -F "token=${YOUR_API_TOKEN}" \
    -F "user=${YOUR_USER_KEY}" \
    -F "title=\"$form\"" \
    -F "message=\"$desc\"" \
    "https://api.pushover.net/1/messages.json" >> pushover.log

exit 0
