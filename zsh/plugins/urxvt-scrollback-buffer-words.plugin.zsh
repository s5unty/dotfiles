# http://superuser.com/questions/117051/how-do-i-save-the-scrollback-buffer-in-urxvt
# http://blog.plenz.com/2012-01/zsh-complete-words-from-tmux-pane.html
_urxvt_scrollback_buffer_words() {
  local expl
  local -a w
  # depends URxvt.print-pipe configuration
  # insure the ~/.Xresources or ~/.Xdefaults:
  #   ...
  #   URxvt.print-pipe:   cat > /tmp/xxx
  #
  /bin/echo -e -n '\e[i'
  w=( ${(u)=$(sleep 0.1; /bin/cat /tmp/xxx)} )
  _wanted values expl 'words from current buffer' compadd -a w
}

zle -C urxvt-scrollback-buffer-words-prefix   complete-word _generic
zle -C urxvt-scrollback-buffer-words-anywhere complete-word _generic
# Alt-Tab:
#   bindkey -M viins "\e\t" urxvt-scrollback-buffer-words-prefix
# Shift-Tab
#   bindkey -M viins "^[[Z" urxvt-scrollback-buffer-words-anywhere
zstyle ':completion:urxvt-scrollback-buffer-words-(prefix|anywhere):*' completer _urxvt_scrollback_buffer_words
zstyle ':completion:urxvt-scrollback-buffer-words-(prefix|anywhere):*' ignore-line current
zstyle ':completion:urxvt-scrollback-buffer-words-anywhere:*' matcher-list 'b:=* m:{A-Za-z}={a-zA-Z}'
