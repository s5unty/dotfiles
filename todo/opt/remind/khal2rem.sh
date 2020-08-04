#!/bin/bash
##
# $ khal list today today
# 08/04/20(二)
# 12:30-13:00 调整usorder域名指向10.1.3.101 ::
# 13:00-13:30 面试邀约 ::  1-4080会议室
# 15:00-15:30 测试通知科科
#
##
# % khal2rem.sh
# REM 2020-08-04 AT 12:30 +30 *25 MSG %1: 调整usorder域名指向10.1.3.101 @ (%2)
# REM 2020-08-04 AT 13:00 +30 *25 MSG %1: 面试邀约 @1-4080会议室 (%2)
# REM 2020-08-04 AT 15:00 +30 *25 MSG %1: 测试通知科科  @ (%2)
####

khal list today today | tail -n +2 \
    | awk -v date=$(date +%Y-%m-%d) '
    {
        time=substr($1,0,5);
        D=substr($0,13);
        split(D, A, " :: ");
        X=gensub(/^\s*/, "", "g", A[2]);
        desc=A[1];
        location=gensub(/\s/, "_", "g", X)
    }
    {
        printf "REM %s AT %s +30 *25 MSG %1: %s @%s (%2)\n", date, time, desc, location
    }
    '
