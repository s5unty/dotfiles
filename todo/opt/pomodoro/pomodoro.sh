#!/bin/sh
# inspired from http://feedelli.org/2012/07/29/bash-command-line-pomodoro-timer.html
# punch-time-tracking: http://code.google.com/p/punch-time-tracking/

# 每个闹钟就固定为 25 分钟，不允许任意设定时间。
# 配合 Punch.py 才能记录钟的使用情况，方便统计。
limit=$((25*60*1000))
step=$((5*60*1000))
# limit=$((25*1000)) # 25秒测试用
# step=$((5*1000))

#### 垂直递增
# while [ $limit -gt 0 ]; do
#     notify-send -u critical -i appointment -t $limit "●"
#     sleep $(($step / 1000))
#     limit=$(($limit - $step))
# done

#### 垂直递减
expire=$limit
while [ $limit -gt 0 ]; do
    notify-send -u critical -i appointment -t $limit "●"
    limit=$(($limit - $step))
done
sleep $(($expire / 1000))

#### 水平递增
# notify-send -u critical -i appointment -t $step "●"
# sleep $(($step / 1000))
# notify-send -u critical -i appointment -t $step "●●"
# sleep $(($step / 1000))
# notify-send -u critical -i appointment -t $step "●●●"
# sleep $(($step / 1000))
# notify-send -u critical -i appointment -t $step "●●●●"
# sleep $(($step / 1000))
# notify-send -u critical -i appointment -t $step "●●●●●"
# sleep $(($step / 1000))

### 水平递减
# 略 :)

# 工作时间结束
doing=$(python $TODO_DIR/opt/punch/Punch.py what | sed 's/Active task: \(.*\) (.*)/\1/g')
notify-send -u critical -i appointment -t $step "Please stop this work and take short break. ☻" "$doing"

# 结束 Punch.py 里面的计时，强迫自己手工重设每个工作闹钟
python $TODO_DIR/opt/punch/Punch.py out > /dev/null 2>&1

