#!/bin/sh -e

if [ -f $HOME/.moc/pid ]; then
    state=`mocp -i | head -1 | sed 's/State: //g'`
    case $state in
    PLAY)
        mocp -G;;
    PAUSE)
        mocp -G;;
    STOP)
        mocp -p;;
    esac
fi
