# ref@http://www.zsh.org/mla/users/2007/msg00976.html
#
autoload -U modify-current-argument
autoload -U split-shell-arguments

#useful when you pasted a url with lots of ^?& stuff in it
#takes a alt-number argument to select type of quoting.
function _quote_word()
{
  q=qqqq
  modify-current-argument '${('$q[1,${NUMERIC:-1}]')ARG}'
}

#useful when you want to put a url back in a browser perhaps, or just
#get the clean name of a tabcompleted file to paste somewhere else.
function _unquote_word()
{
  modify-current-argument '${(Q)ARG}'
}

#change the quoting of a word from one type to another. If the word
#contains spaces you can't use _unquote_word followed by _quote_word
#since it won't be just one word by then.
function _quote_unquote_word()
{
  q=qqqq
  modify-current-argument '${('$q[1,${NUMERIC:-1}]')${(Q)ARG}}'
}

zle -N _quote_word
zle -N _unquote_word
zle -N _quote_unquote_word
