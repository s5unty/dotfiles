##
# 每次断开重连之后，无线键盘的自定义键位和延时灵敏度，都被自动复位了，
# 好在我有个屏保，让我的屏保，在每次退出时，帮我自动执行一段键盘配置。
#
# 屏保启动命令:
#   ----
#   /usr/bin/kitty --name="CMatrix" -T CMatrix \
#       -o background_image="none" -o background="#333333" --watcher="btkb.py" \
#       -e zsh -c "cmatrix -a -b -u 2 -C black"
#   ----
#
# 屏保窗口关闭时:
#   ----
#   pkill xcape
#   setxkbmap -option ctrl:nocaps
#   xcape -e 'Control_L=Escape'
#   xset b off m 3 10 r rate 400 40
#   ----
#
##
# ref: https://github.com/kovidgoyal/kitty/discussions/3311
####

from typing import Any, Dict
from kitty.boss import Boss
from kitty.window import Window
import os

def on_close(boss: Boss, window: Window, data: Dict[str, Any])-> None:
    os.system("pkill xcape; setxkbmap -option ctrl:nocaps && xcape -e 'Control_L=Escape' && xset b off m 3 10 r rate 400 40")
    # os.system("touch /tmp/some; date >> /tmp/some && date >> /tmp/some")
