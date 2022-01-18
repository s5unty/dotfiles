#!/usr/bin/env elvish
##
# $ khal list today today
# 08/04/20(二)
# 12:30-13:00 调整usorder域名指向10.1.3.101 ::
# 13:00-13:30 面试邀约 ::  1-4080会议室
# 15:00-15:30 测试通知科科
#
##
# % khal2rem.el
# REM 2020-08-04 AT 12:30 +30 *25 MSG %1: 调整usorder域名指向10.1.3.101 @_ (%2)
# REM 2020-08-04 AT 13:00 +30 *25 MSG %1: 面试邀约 @1-4080会议室 (%2)
# REM 2020-08-04 AT 15:00 +30 *25 MSG %1: 测试通知科科  @_ (%2)
####

use str

var REMDIR = "/sun/.todo/var"
var @tasks = (khal list today today | egrep "^[0-9]+:[0-9]+")

for task $tasks {
    var date = (date +%Y-%m-%d)
    var time = $task[0..5]
    var rest
    if (==s $task[5..7] "->") {
        set rest = $task[8..]
    } else {
        set rest = $task[12..]
    }

    var desc room
    if (str:contains $rest "::") {
        var @one = (str:split "::" $rest)
        set desc = (str:trim $one[0] " ")
        set room = (str:trim $one[1] " ")
    } else {
        set desc = (str:trim $rest " ")
        set room = ""
    }

    if (==s "" $room) {
        set room = "_"
    } else {
        set room = (str:replace " " "_" $room)
    }

    printf "REM %s AT %s +30 *25 MSG %%1: %s @%s (%%2)\n" $date $time $desc $room
}

# 通知 remind 重新加载脚本
# ========================
# 只有当 remind 监控的文件或目录的最后修改时间(modification time)发生变化时，
# 才能让 remind 更新已缓存了(queue)的通知条目，进而变更 remind 的提醒行为。
# 由于在终端调试 remind 条目时，编辑器的保存操作会自动更新文件及文件所在目录，
# 然而在脚本中修改 remind 条目时，文件或目录的最后修改时间不会发生变化，
# 因此在脚本中修改条目后，必须额外修改 remind 监控的文件或目录的最后修改时间。
#
# 假设启动 remind 的命令是：
#       remind -z -a /your/directory/
#   =>  touch -m /your/directory/
#
# 假设启动 remind 的命令是：
#       remind -z -a /your/remind/file
#   =>  touch -m /your/remind/file
#
touch -m $REMDIR
