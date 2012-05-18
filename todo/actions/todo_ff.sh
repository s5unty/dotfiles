#!/bin/bash

export COLOR_PRIORITY=$AT_BOLDIT
export COLOR_CONTEXT=$AT_BOLD
export COLOR_PROJECT=$AT_UNDERL
export COLOR_DATE=$AT_UNDERL

# Force gawk to behave posixly. Comment out if you get an error about
# no such option -W.
AWK_OPTIONS="-W posix"
if [ "$TODOTXT_PLAIN" -eq "0" ]; then
	awk $AWK_OPTIONS '
	function highlight(colorVar, color) {
		color = ENVIRON[colorVar]
		gsub(/\\+033/, "\033", color)
		return color
	}
	{ color = "DEFAULT" }
	/\(A\)/ { color = "PRI_A" }
	/\(B\)/ { color = "PRI_B" }
	/\(C\)/ { color = "PRI_C" }
	/\([D-Z]\)/ { color = "PRI_X" }
	/ x / { color = "COLOR_DONE" }
	{
        gsub(/ \([A-Z]\) /, highlight("COLOR_PRIORITY") "&" highlight(color));
		gsub(/@[^ ]*/, highlight("COLOR_CONTEXT") "&" highlight(color));
		gsub(/\+[^ ]*/, highlight("COLOR_PROJECT") "&" highlight(color));
        gsub(/([0-9]{4}(-[0-9]{2}){2}|[0-9]{1,2}[-/][0-9]{1,2})/, highlight("COLOR_DATE") "&" highlight(color));
		print
	}
'
else
	cat
fi