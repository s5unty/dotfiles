#compdef todo.sh
# put this script into:
#   /usr/share/zsh/functions/Completion/Unix/_todo.sh
#
# See http://todotxt.com for todo.sh.
#
# Featurettes:
#  - "replace" will complete the original text for editing
#  - completing priorities will cycle through A to Z (even without
#    menu completion)
#  - list and listall will complete +<project> and @<where> from
#    values in existing entries
#  - will complete after + and @ if typed in message text
#
# Ex addons:
#  - https://github.com/inkarkat/todo.txt-cli-ex
#

setopt localoptions braceccl

local expl curcontext="$curcontext" state line pri nextstate item
local -a cmdlist itemlist match mbegin mend
integer NORMARG

_arguments -s -n : \
  '-d[alternate config file]:config file:_files' \
  '-f[force, no confirmation]' \
  '-h[display help]' \
  '-p[plain mode, no colours]' \
  '-v[verbose mode, confirmation messages]' \
  '-V[display version etc.]' \
  '1:command:->commands' \
  '*:arguments:->arguments' && return 0

local projmsg="context or project"
local txtmsg="text with contexts or projects"

# Skip "command" as command prefix if words after
if [[ $words[NORMARG] == command && NORMARG -lt CURRENT ]]; then
  (( NORMARG++ ))
fi

case $state in
  (commands)
  cmdlist=(
    "add:add TODO ITEM to todo.txt."
    "addm:add TODO ITEMs, one per line, to todo.txt."
    "addto:add text to file (not item)"
    "append:adds to item on line NUMBER the text TEXT."
    "archive:moves done items from todo.txt to done.txt."
    "command:run internal commands only"
    "del:deletes the item on line NUMBER in todo.txt."
    "depri:remove prioritization from item"
    "do:marks item on line NUMBER as done in todo.txt."
    "help:display help"
    "list:displays all todo items containing TERM(s), sorted by priority."
    "listall:displays items including done ones containing TERM(s)"
    "listcon:list all contexts"
    "listfile:display all files in .todo directory"
    "listpri:displays all items prioritized at PRIORITY."
    "move:move item between files"
    "prepend:adds to the beginning of the item on line NUMBER text TEXT."
    "pri:adds or replace in NUMBER the priority PRIORITY (upper case letter)."
    "replace:replace in NUMBER the TEXT."
    "remdup:remove exact duplicates from todo.txt."
    "report:adds the number of open and done items to report.txt."
    "add:THING I NEED TO DO t:tomorrow u:(next week)"
    "addagain:[TERM...]"
    "addagain:ITEM#[, ITEM#, ...] [TERM...]"
    "addconsider:THING I MIGHT SOON DO"
    "adddo:THING I NEEDED TO DO RIGHT NOW"
    "addendum:THING I NEED TO DO +project @context"
    "addescalating:DATESPAN THING I NEED TO DO"
    "addlike:[ITEM#] THING SIMILAR TO ITEM#"
    "addm:[-b prefix] [-e suffix] FIRST THING I NEED TO DO +project1 @context"
    "SECOND:THING I NEED TO DO +project2 @context"
    "addopportunity:DATE THING I COULD DO"
    "addprereq:ITEM#[, ITEM#, ...] THING DEPENDING ON ITEM#"
    "addpri:PRIORITY THING I NEED TO DO +project @context"
    "addshortly:DATE THING I NEED TO DO"
    "addstart:THING I NEED TO DO +project @context"
    "archive"
    "archive:TERM..."
    "archive:ITEM#[, ITEM#, ...]"
    "backup"
    "birdseye:[(open|completed|all)-(projects|contexts) [...]]"
    "blockerview:[TERM...]"
    "browse:ITEM#[, ITEM#, ...]"
    "browse:[TERM...]"
    "bump:ITEM#[, ITEM#, ...]"
    "cheat:[pri|marker|syntax]"
    "clone:ITEM# [PATTERN REPLACEMENT ...]"
    "comment:ITEM#[, ITEM#, ITEM#, ...] COMMENT"
    "consider:ITEM#[, ITEM#, ...]"
    "contextstat:[-a] [TERM...]"
    "contextview:[-a] [TERM...]"
    "cv:[-a] [TERM...]"
    "dashboard:[TERM...]"
    "defragment"
    "del:ITEM#[, ITEM#, ITEM#, ...] [TERM]"
    "depri:ITEM#[, ITEM#, ITEM#, ...]|all|[PRIORITIES] [on DATE|DATE-] [COMMENT]"
    "depri:[on DATE|DATE-] ITEM#[, ITEM#, ITEM#, ...]|all|[PRIORITIES] [COMMENT]"
    "depri:[never|on none] ITEM#[, ITEM#, ITEM#, ...]|all|[PRIORITIES] [COMMENT]"
    "depview:[TERM...]"
    "did:ITEM#[, ITEM#, ITEM#, ...] [on] DATE [COMMENT]"
    "did:ITEM#[, ITEM#, ITEM#, ...] after DATESPAN [COMMENT]"
    "did:ITEM#[, ITEM#, ITEM#, ...] the same|next day [COMMENT]"
    "do:ITEM#[, ITEM#, ITEM#, ...] [COMMENT]"
    "do:trash ITEM#[, ITEM#, ITEM#, ...] [COMMENT]"
    "dup:ITEM# del|trash [--hard] DUPITEM#[, DUPITEM#, ...]"
    "dup:goal GOAL ITEM#[, ITEM#, ...]"
    "dup:link ITEM# ITEM#[, ITEM#, ...]"
    "edit:[ITEM#] [SRC]"
    "here:[-s [NUM]] [TERM...]"
    "incorporate"
    "inout:[-s] [DATE] [TERM...]"
    "last:[TERM...]"
    "latest:[-a] [TERM...]"
    "lt:[TERM...]"
    "link:ITEM# TARGET#[, TARGET#, ...]"
    "link:ITEM# none"
    "listblockers:[TERM...]"
    "listbydate:[-a] [TERM...]"
    "ls:[TERM...]"
    "ls:ITEM#[, ITEM#, ...] [TERM...]"
    "lsa:[TERM...]"
    "lsac:[TERM...]"
    "lsaprj:[TERM...]"
    "lsarchive:[TERM...]"
    "lsbumped:[TERM...]"
    "lsconsidered:[TERM...]"
    "lsdo:[TERM...]"
    "lsdone:[TERM...]"
    "lsdue:[DATE] [TERM...]"
    "lsopportunities:[TERM...]"
    "lspriprj:[PRIORITIES] [TERM...]"
    "lsstarted:[TERM...]"
    "lstrash:[TERM...]"
    "lstrashable:[TERM...]"
    "lstrashed:[TERM...]"
    "lswait:[TERM...]"
    "lswait:for DEPITEM#[, DEPITEM#, ...]"
    "lswait:for REASON[, REASON, ...]"
    "mail:[-t] [-e | -m MESSAGE] TERM..."
    "mail:[-t] [-e | -m MESSAGE] ITEM#, ITEM#[, ITEM#, ...]"
    "mail:[-t] [-e | -m MESSAGE] -s ITEM#"
    "oldest:[-a] [TERM...]"
    "opportunity:ITEM#[, ITEM#, ITEM#, ...] DATE"
    "pri:PRIORITY|none [on DATE|DATE-] [until DATE|-DATE] ITEM#[, ITEM#, ...] [COMMENT]"
    "pri:PRIORITY|none ITEM#[, ITEM#, ...] [on DATE|DATE-] [until DATE|-DATE] [COMMENT]"
    "pri:ITEM#[, ITEM#, ...] PRIORITY|none [on DATE|DATE-] [until DATE|-DATE] [COMMENT]"
    "projectstat:[-a] [TERM...]"
    "projectview:[-a] [TERM...]"
    "pv:[-a] [TERM...]"
    "recur:ITEM# RELATIVEDATE"
    "recur:ITEM# none|never"
    "recur:ITEM# off"
    "recur:[list [TERM...]]"
    "schedule:DATE|none|never|off|del|rm ITEM#[, ITEM#, ...]"
    "schedule:ITEM#[, ITEM#, ...] DATE|none|never|off|del|rm"
    "schedule:[(all|now|on DATE|for DATE|future [on DATE]) [TERM...]]"
    "split:ITEM# [PATTERN]"
    "start:[on DATE|DATE-] [until DATE|-DATE] ITEM#[, ITEM#, ...] [COMMENT]"
    "start:ITEM#[, ITEM#, ...] [on DATE|DATE-] [until DATE|-DATE] [COMMENT]"
    "stop:ITEM#[, ITEM#, ITEM#, ...]|all [on DATE|DATE-] [COMMENT]"
    "stop:[on DATE|DATE-] ITEM#[, ITEM#, ITEM#, ...]|all [COMMENT]"
    "subst:ITEM# PATTERN REPLACEMENT [PATTERN REPLACEMENT ...]"
    "summary:[TERM...]"
    "tasks"
    "tasks:ACTION [ACTION_ARGUMENTS]"
    "trash:[--hard] ITEM#[, ITEM#, ITEM#, ...] [COMMENT]"
    "uncomment:[-q] ITEM#"
    "undo"
    "undo:ITEM#[, ITEM#, ITEM#, ...]"
    "until:DATE ITEM#[, ITEM#, ...]"
    "until:ITEM#[, ITEM#, ...] DATE"
    "until:DATE zap ITEM#[, ITEM#, ...]"
    "until:ITEM#[, ITEM#, ...] zap DATE"
    "until:zap [none|never|off|del|rm] ITEM#[, ITEM#, ...]"
    "until:ITEM#[, ITEM#, ...] zap [none|never|off|del|rm]"
    "until:none|never|off|del|rm ITEM#[, ITEM#, ...]"
    "until:ITEM#[, ITEM#, ...] none|never|off|del|rm"
    "until:[(any|all|now|on DATE|soon [on DATE]|for DATE) [TERM...]]"
    "untrash:last|ITEM#[, ITEM#, ITEM#, ...]"
    "unwait:ITEM#[, ITEM#, ...]"
    "unwait:ITEM#[, ITEM#, ...] PRIORITY"
    "unwait:[ITEM#, ...] REASON for Waiting[, REASON, ...]"
    "unwait:[ITEM#, ...] for DEPITEM#[, DEPITEM#, ...]"
    "wait:ITEM#[, ITEM#, ...] REASON for Waiting[, REASON, ...]"
    "wait:ITEM#[, ITEM#, ...] for DEPITEM#[, DEPITEM#, ...]"
    "what:[DATE] [TERM...]"
  )
  _describe -t todo-commands 'todo.sh command' cmdlist
  ;;

  (arguments)
  case $words[NORMARG] in
    (append|command|del|move|mv|prepend|pri|replace|rm)
    if (( NORMARG == CURRENT - 1 )); then
      nextstate=item
    else
      case $words[NORMARG] in
	(pri)
	nextstate=pri
	;;
	(append|prepend)
	nextstate=proj
	;;
	(move|mv)
	nextstate=file
	;;
	(replace)
	item=${words[CURRENT-1]##0##}
	compadd -Q -- "${(qq)$(todo.sh -p list "^[ 0]*$item " | sed '/^--/,$d')##<-> (\([A-Z]\) |)}"
	;;
      esac
    fi
    ;;

    (depri|do|dp)
    nextstate=item
    ;;

    (a|add|addm|list|ls|listall|lsa)
    nextstate=proj
    ;;

    (addto)
    if (( NORMARG == CURRENT - 1 )); then
      nextstate=file
    else
      nexstate=proj
    fi
    ;;

    (listfile|lf)
    if (( NORMARG == CURRENT -1 )); then
      nextstate=file
    else
      _message "Term to search file for"
    fi
    ;;

    (listpri|lsp)
    nextstate=pri
    ;;

    (*)
    return 1
    ;;
  esac
  ;;
esac

case $nextstate in
  (file)
  _path_files -W ~/.todo
  ;;

  (item)
  itemlist=(${${(M)${(f)"$(todo.sh -p list | sed '/^--/,$d')"}##<-> *}/(#b)(<->) (*)/${match[1]}:${match[2]}})
  _describe -t todo-items 'todo item' itemlist
  ;;

  (pri)
  if [[ $words[CURRENT] = (|[A-Z]) ]]; then
    if [[ $words[CURRENT] = (|Z) ]]; then
      pri=A
    else
      # cycle priority
      pri=$words[CURRENT]
      pri=${(#)$(( #pri + 1 ))}
    fi
    _wanted priority expl 'priority' compadd -U -S '' -- $pri
  else
    _wanted priority expl 'priority' compadd {A-Z}
  fi
  ;;

  (proj)
  # This completes stuff beginning with + (projects) or @ (contexts);
  # these are todo.sh conventions.
  if [[ ! -prefix + && ! -prefix @ ]]; then
    projmsg=$txtmsg
  fi
  # In case there are quotes, ignore anything up to whitespace before
  # the + or @ (which may not even be there yet).
  compset -P '*[[:space:]]'
  _wanted search expl $projmsg \
    compadd $(todo.sh lsaprj) $(todo.sh lsac)
  ;;
esac
