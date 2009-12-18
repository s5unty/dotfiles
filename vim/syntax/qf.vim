" Vim syntax file
" Language:	Quickfix window

" A bunch of useful C keywords
syn match	qfFileName	"^[^|]*" nextgroup=qfSeparator
syn match	qfSeparator	"|" nextgroup=qfLineNr contained
syn match	qfLineNr	"[^|]*" contained contains=qfError,qfWarning
syn match	qfError		"error"
syn match	qfWarning	"warning"

" The default highlighting.
hi def link qfFileName	Directory
hi def link qfLineNr	LineNr
hi def link qfError	Error
hi def link qfWarning   Todo

let b:current_syntax = "qf"
