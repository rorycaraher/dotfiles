# syntax-highlighting cat, no pager
alias cat='bat --paging=never'
alias catp='bat -pp --paging=never'

# colorised man pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export PAGER='bat --paging=always'

export GIT_PAGER='less -R'
