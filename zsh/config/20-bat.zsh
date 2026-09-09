# cat replacement — syntax highlighting, no line numbers or paging by
# default, so it behaves like plain `cat` unless you ask for more
alias cat='bat --paging=never'

# use bat as a colorized man-page renderer
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# use bat as the default pager for anything that respects $PAGER
export PAGER='bat --paging=always'
