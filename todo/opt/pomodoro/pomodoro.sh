#!/bin/zsh
# inspired from http://feedelli.org/2012/07/29/bash-command-line-pomodoro-timer.html
# punch-time-tracking: http://code.google.com/p/punch-time-tracking/
#
# with awesome-client, you need do something in your rc.lua:
#
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
#
clean_up() {
    # 结束 Punch.py 里面的计时，强迫自己手工重设每个工作闹钟
    python $TODO_DIR/opt/punch/Punch.py out > /dev/null 2>&1

    echo "pomodoro:set_background_color(theme.bg_normal);pomodoro:set_value(0);pomodoro:set_width(1);" | awesome-client
	exit 0
}
trap clean_up HUP INT TERM KILL

work=$((25*60))
rest=$((5*60))
turn=${2}

for t in $(seq ${turn}); do
    echo "pomodoro:set_background_color('#494B4F');pomodoro:set_width(100);" | awesome-client
    # 工作时间开始
    for i in $(seq 100); do
        echo "pomodoro:set_value(${i})" | awesome-client
        sleep $(echo "scale=3;${work}/100" | bc)
    done

    # 工作时间结束
    doing=$(python $TODO_DIR/opt/punch/Punch.py what | sed 's/Active task: \(.*\) (.*)/\1/g')
    echo 'naughty.notify({ margin = 4, position = "bottom_left", timeout=120, text = "Time to stop work and take a little break."})' | awesome-client

    # 休息时间开始
    for i in $(seq 100); do
        j=$((100-i+1))
        echo "pomodoro:set_width(${j})" | awesome-client
        sleep $(echo "scale=3;${rest}/100" | bc)
    done
done
clean_up
