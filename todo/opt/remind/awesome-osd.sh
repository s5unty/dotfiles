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
form=$(echo ${form} | sed -e 's/\(^.*\)$/<span color=\\"#FFFF00\\">\1<\/span>/g')                        # tdelta

desc=$(echo ${desc} | sed -e 's/</＜/' | sed -e 's/>/＞/')                                               # fix bug
desc=$(echo ${desc} | sed -e 's/\(^(.)\) /<span color=\\"#FF0000\\">\1<\/span> /')                       # priority
desc=$(echo ${desc} | sed -e 's/\(\(\(^@\)\|\( @\)\)[^ <]*\)/<span color=\\"#00FF00\\">\1<\/span>/g')    # context
desc=$(echo ${desc} | sed -e 's/\(\(\(^+\)\|\( +\)\)[^ <]*\)/<span color=\\"#00FFFF\\">\1<\/span>/g')    # project
desc=$(echo ${desc} | sed -e 's/\(^.*\)$/<span color=\\"#FFFFFF\\">\1<\/span>/g')                        # normal

/bin/echo -E 'naughty = require("naughty"); naughty.notify({opacity = 0.9, margin = 6, position = "bottom_right", text = '\"${form} ${desc}\"', timeout=0})' | awesome-client
exit 0

