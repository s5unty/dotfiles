#!/usr/bin/env zsh
# -*- mode: zsh; sh-indentation: 2; indent-tabs-mode: nil; sh-basic-offset: 2; -*-
# vim: ft=zsh sw=2 ts=2 et
#
# This is a clean-room implementation of the Fish shell's history search
# feature, where you can enter any part of any previous command and press
# the UP and DOWN arrow keys to cycle through all matching commands.
#
# This was originally implemented by Peter Stephenson[1], who published it to
# the ZSH users mailing list (thereby making it public domain) in September
# 2009.  It was later revised revised by Guido van Steen, who released it
# under the BSD license as part of the fizsh[2] project in January 2011.
#
# It was later extracted from fizsh[2], repackaged as both an oh-my-zsh[3]
# plugin and as an independently sourceable ZSH script, and published as
# zsh-history-substring-search[4] by Suraj N. Kurapati in January 2011.
#
# [1] http://www.zsh.org/mla/users/2009/msg00818.html
# [2] http://sourceforge.net/projects/fizsh/
# [3] http://github.com/robbyrussell/oh-my-zsh
# [4] http://github.com/sunaku/zsh-history-substring-search
#

zsh-history-substring-search-backward() {
  emulate -L zsh
  setopt extendedglob
  zmodload -i zsh/parameter

  # check if _zsh_highlight-zle-buffer is available
  # so that calls to this function will not fail.
  zsh_highlighting_available=0
  (( $+functions[_zsh_highlight-zle-buffer] )) && zsh_highlighting_available=1

  if [[ ! (
    (${WIDGET/backward/forward} = ${LASTWIDGET/backward/forward}) ||
    (${WIDGET/forward/backward} = ${LASTWIDGET/forward/backward})
  ) ]]; then
    ordinary_highlight="bg=black,fg=white,bold"
    out_of_matches_highlight="bg=red,fg=white,bold"
    # set the type of highlighting
    search=${BUFFER//(#m)[\][()\\*?#<>~^]/\\$MATCH}
    # $BUFFER contains the text that is in the command-line currently.  we put
    # an extra "\\" before meta characters such as "\(" and "\)", so that they
    # become "\\\|" and "\\\("
    search4later=${BUFFER}
    # for the purpose of highlighting we will also keep a version without
    # doubly-escaped meta characters
    matches=(${(kon)history[(R)*${search}*]})
    # find all occurrences of the pattern *${seach}* within the history file
    # (k) turns it an array of line numbers. (on) seems to remove duplicates.
    # (on) are default options. they can be turned off by (ON).
    number_of_matches=${#matches}
    let "number_of_matches_plus_one = $number_of_matches + 1"
    # define the range of value that $match_number can take:
    # [0, $number_of_matches_plus_one]
    let "number_of_matches_minus_one = $number_of_matches - 1"
    # handy for later
    let "match_number=$number_of_matches_plus_one"
    # initial value of $match_number, which can initially only be decreased by
    # ${WIDGET/forward/backward}
  fi

  if [[ $WIDGET = *backward* ]]; then # we have pressed arrow-up
    if [[ ($match_number -ge 2 && $match_number -le $number_of_matches_plus_one) ]]; then
      let "match_number = $match_number - 1"
      command_to_be_retrieved=$(fc -ln $matches[$match_number] $matches[$match_number])
      BUFFER=$command_to_be_retrieved
      if [[ ( $zsh_highlighting_available = 1 ) ]]; then
        _zsh_highlight-zle-buffer
      fi
      if [[ $search4later != "" ]]; then # search string was not empty: highlight it
        : ${(S)BUFFER##(#m)($search4later##)}
        # among other things the following expression yields a variable $MEND,
        # which indicates the end position of the first occurrence of $search
        # in $BUFFER
        let "my_mbegin = $MEND - $#search4later"
        region_highlight=("$my_mbegin $MEND $ordinary_highlight")
      fi
    else
      if [[ ($match_number -eq 1) ]]; then
      # we will move out of the matches
        let "match_number = $match_number - 1"
        old_buffer_backward=$BUFFER
        BUFFER=$search4later
        if [[ ( $zsh_highlighting_available = 1 ) ]]; then
          _zsh_highlight-zle-buffer
        fi
        if [[ $search4later != "" ]]; then
          : ${(S)BUFFER##(#m)($search4later##)}
          let "my_mbegin = $MEND - $#search4later"
          region_highlight=("$my_mbegin $MEND $out_of_matches_highlight")
          # this is slightly more informative than highlighting
          # that fish performs
        fi
      else
        if [[ ($match_number -eq $number_of_matches_plus_one ) ]]; then
        # we will move back to the matches
          let "match_number = $match_number - 1"
          BUFFER=$old_buffer_forward
          if [[ ( $zsh_highlighting_available = 1 ) ]]; then
            _zsh_highlight-zle-buffer
          fi
          if [[ $search4later != "" ]]; then
            : ${(S)BUFFER##(#m)($search4later##)}
            let "my_mbegin = $MEND - $#search4later"
            region_highlight=("$my_mbegin $MEND $ordinary_highlight")
          fi
        fi
      fi
    fi
  else # arrow-down
    if [[ ($match_number -ge 0 && $match_number -le $number_of_matches_minus_one) ]]; then
      let "match_number = $match_number + 1"
      command_to_be_retrieved=$(fc -ln $matches[$match_number] $matches[$match_number])
      BUFFER=$command_to_be_retrieved
      if [[ ( $zsh_highlighting_available = 1 ) ]]; then
        _zsh_highlight-zle-buffer
      fi
      if [[ $search4later != "" ]]; then
        : ${(S)BUFFER##(#m)($search4later##)}
        let "my_mbegin = $MEND - $#search4later"
        region_highlight=("$my_mbegin $MEND $ordinary_highlight")
      fi
    else
      if [[ ($match_number -eq $number_of_matches ) ]]; then
        let "match_number = $match_number + 1"
        old_buffer_forward=$BUFFER
        BUFFER=$search4later
        if [[ ( $zsh_highlighting_available = 1 ) ]]; then
          _zsh_highlight-zle-buffer
        fi
        if [[ $search4later != "" ]]; then
          : ${(S)BUFFER##(#m)($search4later##)}
          let "my_mbegin = $MEND - $#search4later"
          region_highlight=("$my_mbegin $MEND $out_of_matches_highlight")
        fi
      else
        if [[ ($match_number -eq 0 ) ]]; then
          let "match_number = $match_number + 1"
          BUFFER=$old_buffer_backward
          if [[ ( $zsh_highlighting_available = 1 ) ]]; then
            _zsh_highlight-zle-buffer
          fi
          if [[ $search4later != "" ]]; then
            : ${(S)BUFFER##(#m)($search4later##)}
            let "my_mbegin = $MEND - $#search4later"
            region_highlight=("$my_mbegin $MEND $ordinary_highlight")
          fi
        fi
      fi
    fi
  fi
  zle .end-of-line

  # for debugging purposes:
  # zle -R "mn: "$match_number" m#: "${#matches}
  # read -k -t 200 && zle -U $REPLY
}

zle -N zsh-history-substring-search-forward zsh-history-substring-search-backward
zle -N zsh-history-substring-search-backward
#bindkey '\e[A' zsh-history-substring-search-backward
#bindkey '\e[B' zsh-history-substring-search-forward
