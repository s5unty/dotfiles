#!/bin/zsh
# inspired on: https://github.com/jkrehm/todotxt-cli-addons
#
# 功能：
#   处理 [todotxt][1] [数据文件][2]中含有 **提醒标记** 的任务事项，
#   把他们格式化之后另存为 [remind][3] 格式的[数据文件][4]。
#
# 提醒标记(可自定义、符合 todotxt [格式][2]即可)：
#   rem:(.*)
#
# 时间戳置换标记(man 详情[THE SUBSTITUTION FILTER][4])：
#   %1
#   %b
#   sub:{.*}
#
# 示例：
# (T)odotxt 格式的文本、(R)emind 格式的文本
# (N)otify 收到通知时看到的文本、不包括 <= 及其后面的备注
#
#   1. 下午两点开会
#
#     T: 下午两点开会 @106 rem:(13:30)
#     R: REM AT 13:30 MSG %1: 下午两点开会 @106  (%2)
#     N: 现在: 下午两点开会 @106  (1:30pm)                              <= 13:00收到第一次也是最后一次通知
#
#   2. 下午两点开会，提前半小时提醒
#
#     T: 下午开会 @106 rem:(14:00 +30)
#     R: REM AT 14:00 +30 MSG %1: 下午开会 @106  (%2)
#     N: 30分钟后: 下午开会 @106  (2:00pm)                              <= 13:30收到第一次通知
#     N: 现在: 下午开会 @106  (2:00pm)                                  <= 14:00收到最后一次通知
#
#   3. 26号下午三点开会，提前半小时和五分钟，各提醒一次
#
#     T: 又开会 @504 rem:(26 at 15:00 +30 *25)
#     R: REM 26 AT 15:00 +30 *25 MSG %1: 又开会 @504  (%2)
#     N: 30分钟后: 又开会 @504  (3:00pm)                                <= 26号下午14:30收到第一次通知
#     N: 5分钟后: 又开会 @504  (3:00pm)                                 <= 26号下午14:55收到最后一次通知
#
#   4. 下午有课
#
#     T: 上课 @601 rem:(mon, tue, fri at 17:00 +5)
#     R: REM mon, tue, fri AT 17:00 +5 MSG %1: 上课 @601  (%2)
#     N: 5分钟后: 上课 @601  (5:00pm)                                   <= 星期一、二、五的下午16:55收到第一次通知
#     N: 现在: 上课 @601  (5:00pm)                                      <= 星期一、二、五的下午17:00收到第二次通知
#
#   5. 续费提醒
#
#     T: 域名到期 rem:(2012-12-26 +2)
#     R: REM 2012-12-26 +2 MSG %b: 域名到期
#     N: 2天后: 域名到期                                                <= 2012-12-24凌晨收到第一次通知
#     N: 明天: 域名到期                                                 <= 2012-12-25凌晨收到第二次通知
#     N: 今天: 域名到期                                                 <= 2012-12-26凌晨收到最后一次通知
#
#   6. 生日提醒
#
#     T: 谁的[$Uy - 1955]岁生日 rem:(26 Dec [$Uy] -15 *7 UNTIL 26 Dec [$Uy]) sub:{[dosubst("%b%", date($Uy, $Um, 26))]}
#     R: REM 26 Dec [$Uy] -15 *7 UNTIL 26 Dec [$Uy] MSG [dosubst("%b%", date($Uy, $Um, 26))]: 谁的[$Uy - 1955]岁生日
#     N: 15天后: 谁的57岁生日                                           <= 2012年的12-11凌晨收到当年第一次通知
#     N: 8天后: 谁的58岁生日                                            <= 2013年的12-18凌晨收到当年第二次通知
#     N: 明天: 谁的59岁生日                                             <= 2014年的12-25凌晨收到当年最后一次通知
#
# [1]: http://todotxt.com/
# [2]: https://github.com/ginatrapani/todo.txt-cli/wiki/The-Todo.txt-Format
# [3]: http://www.roaringpenguin.com/products/remind
# [4]: $ man remind
#
# PS: 计算复杂日期可以考虑 remind 命令
#
#   1. 打印未来 10 天的日期
#
#       $ (echo 'banner %'; echo 'msg [today()]%') | remind - '*10'
#
#   2. 打印下个月第一个星期一的日期
#
#       $ (echo 'banner %'; echo 'msg [evaltrig("Mon 1", $T)]%') | remind -
#
#   3. 打印这个月最后一个星期五的日期                                   <= 下个月第一个星期五的前 7 天
#
#       $ (echo 'banner %'; echo 'msg [evaltrig("Fri 1", $T) - 7]%') | remind -
#
only_time_spec="\s*[0-9]{1,2}:[0-9]{1,2}( \+[0-9]{1,4})?( \*[0-9]{1,3})?\s*"
date_time_spec=".+\s*[aA][tT]"$only_time_spec
DATA_DIRECTORY="/sun/.todo/var"

for TODO_FILE in $DATA_DIRECTORY/**/todo.log; do
    DOTREMINDERS="${TODO_FILE%%/todo.log}.rem"
    cat /dev/null > $DOTREMINDERS

    while read line; do
        if ! echo $line | grep -q 'rem:(.*)'; then
            continue    # 忽略没有 rem: 标记的行
        fi

        if echo $line | grep -q '^[xX]'; then
            continue    # 忽略已标记为完成的任务
        fi

        # 删除 todotxt 格式的时间戳标记
        line=$(echo $line | sed \
            -e 's/[ ]\?[0-9]\{2,4\}[-/][0-9]\{1,2\}[-/][0-9]\{1,2\}[ ]//' \
            -e 's/[ ]\+[tuxs]:[0-9]\{2,4\}[-/.][0-9]\{1,2\}[-/.][0-9]\{1,2\}\([ ]\+\|$\)/ /g')

        # 解析出用于 remind 的**提醒标记**
        spec=$(echo $line | sed -e 's/.*rem:(\(.*\)).*/\1/g')

        if [[ $spec =~ $date_time_spec ]]; then
            # 日期＋时间
            rem=$(echo $line | sed -e 's,\(.*\)rem:(\(.*\)),REM \2 MSG %1: \1 (%2),g' -e 's, at ,\U&,g')
        elif [[ $spec =~ $only_time_spec ]]; then
            # 只有时间
            rem=$(echo $line | sed -e 's,\(.*\)rem:(\(.*\)),REM AT \2 MSG \%1: \1 (%2),g')
        else
            # 只有日期
            if echo $line | grep -q 'sub:{.*}'; then
                sub=$(echo $line | sed -e 's/.*sub:{\(.*\)}.*/\1/g')
            else
                sub="%b"    # 没有自定义时间戳置换标记，默认使用 %b
            fi
            rem=$(echo $line | sed -e 's,\(.*\)rem:(\(.*\)),REM \2 AT 00:00 MSG '$sub': \1,g')
        fi

        echo $rem >> $DOTREMINDERS
    done < $TODO_FILE

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
    touch -m "$DATA_DIRECTORY"
done
