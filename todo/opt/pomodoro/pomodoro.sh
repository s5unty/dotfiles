#!/bin/zsh
# inspired from http://feedelli.org/2012/07/29/bash-command-line-pomodoro-timer.html
# punch-time-tracking: http://code.google.com/p/punch-time-tracking/
# toggl-cli: https://github.com/drobertadams/toggl-cli
#
# with awesome-client, you need do something in your rc.lua:
#
#       [awesome-3.5.x]
#       ----
#       ...
#       require("awful.remote") -- make `awesome-client` work
#       ...
#       pomodoro = awful.widget.progressbar()
#       pomodoro:set_max_value(100)
#       pomodoro:set_background_color('#494B4F')
#       pomodoro:set_color('#AECF96')
#       pomodoro:set_gradient_colors({ '#AECF96', '#88A175', '#FF5656' })
#       pomodoro:set_ticks(true)
#       ...
#       mywibox[s].widgets = {
#           ...
#           mytaglist[s],
#           pomodoro.widget,    -- right here
#       ...
#       ----
#
#       [awesome-4.x]
#       ----
#       ...
#       require("awful.remote") -- make `awesome-client` happy
#       ...
#       pomodoro = wibox.widget.progressbar {}
#       pomodoro.forced_width     = 0
#       pomodoro.max_value        = 100
#       pomodoro.background_color = theme.bg_normal
#       pomodoro.color            = { type = "linear", from = {0, 0}, to = {100, 0}, stops = { { 0, '#AECF96' }, { 0.25, "#88A175" }, { 1, "#FF5656" } } }
#       pomodoro.ticks            = true -- false:平滑的整体，true:间隙的个体
#       ...
#       mywibox[s].widgets = {
#           ...
#           mytaglist[s],
#           pomodoro,    -- right here
#       ...
#       ----
#
# zsh/bash alias:
#
#       alias td1="(${TODO_DIR}/opt/pomodoro/pomodoro.sh '' 1 &)"
#       alias td2="(${TODO_DIR}/opt/pomodoro/pomodoro.sh '' 2 &)"
#
#
clean_up() {
    todo.sh stop $(cat ${TODO_DIR}/var/latest.tid) > /dev/null 2>&1

    # 结束 Punch.py 里面的计时，强迫自己手工重设每个工作闹钟
    # python $TODO_DIR/opt/punch/Punch.py out > /dev/null 2>&1
    #
    # 计时改由在线的 Toggl 服务实现
    # $TODO_DIR/opt/toggl/toggl.py stop > /dev/null 2>&1

    echo "pomodoro:set_background_color(theme.bg_normal);pomodoro:set_value(0);pomodoro.forced_width = 0;" | awesome-client
	exit 0
}
trap clean_up HUP INT TERM KILL

work=$((25*60))
rest=$((5*60))
tdid=${1}
turn=${2}

for t in $(seq ${turn}); do
    echo "pomodoro:set_background_color('#494B4F');pomodoro.forced_width = 200;" | awesome-client
    # 工作时间开始
    for i in $(seq 200); do
        echo "pomodoro:set_value(${i})" | awesome-client
        sleep $(echo "scale=3;${work}/200" | bc)
    done

    # 工作时间结束
    echo "local naughty = require('naughty'); naughty.notify({ margin = 5, position = 'bottom_left', timeout=${rest}, text = 'Time to stop work and take a little rest.'})" | awesome-client

    # 休息时间开始
    for i in $(seq 200); do
        j=$((200-i+1))
        echo "pomodoro.forced_width = ${j}" | awesome-client
        sleep $(echo "scale=3;${rest}/200" | bc)
    done
done
clean_up
