#!/bin/zsh

#$HOME/.local/bin/notmuch-address $@;
/usr/bin/abook --mutt-query $@;
if [[ $? == 0 ]]; then
	/sun/.mutt/mutt-ldap.py $@ 2>/dev/null;
fi;
