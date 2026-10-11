if exists("b:current_syntax")
  finish
endif

syntax case ignore

syntax match   applescriptLineComment "--.*$"
syntax region  applescriptBlockComment start="(\*" end="\*)"
syntax region  applescriptString start=+"+ skip=+\\"+ end=+"+

syntax match   applescriptNumber "\<\d\+\(\.\d\+\)\?\>"

syntax keyword applescriptBoolean true false missing value
syntax keyword applescriptConstant pi it me my
syntax keyword applescriptKeyword tell end on run script property set get to return
syntax keyword applescriptKeyword if then else repeat while until with without given
syntax keyword applescriptKeyword try error considering ignoring of in as from by
syntax keyword applescriptKeyword each times is not and or
syntax keyword applescriptType application text integer real list record string boolean date file alias

syntax match   applescriptOperator "[&¬≠≤≥]"

highlight default link applescriptLineComment   Comment
highlight default link applescriptBlockComment  Comment
highlight default link applescriptString        String
highlight default link applescriptNumber        Number
highlight default link applescriptBoolean       Boolean
highlight default link applescriptConstant      Constant
highlight default link applescriptKeyword       Statement
highlight default link applescriptType          Type
highlight default link applescriptOperator      Operator

let b:current_syntax = "applescript"
