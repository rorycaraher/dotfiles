setopt AUTO_CD
setopt AUTO_PUSHD          # cd pushes onto the directory stack automatically
setopt PUSHD_IGNORE_DUPS   # don't push duplicate entries onto the stack
setopt PUSHDMINUS          # cd -N counts from the other end (see below)

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
