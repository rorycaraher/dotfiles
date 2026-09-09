# Where history is stored, and how much of it to keep
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000        # lines kept in memory per session
SAVEHIST=50000        # lines kept in the history file

setopt EXTENDED_HISTORY       # record timestamp + duration of each command
setopt INC_APPEND_HISTORY     # write to HISTFILE immediately, not just on shell exit
setopt SHARE_HISTORY          # share history across all open terminal sessions live
setopt HIST_EXPIRE_DUPS_FIRST # when trimming, drop duplicates before unique commands
setopt HIST_IGNORE_DUPS       # don't record a command if it's the same as the previous one
setopt HIST_IGNORE_ALL_DUPS   # remove older duplicate when a repeated command is added
setopt HIST_FIND_NO_DUPS      # skip duplicates when searching history (e.g. ctrl+r)
setopt HIST_IGNORE_SPACE      # don't record commands that start with a space
setopt HIST_SAVE_NO_DUPS      # don't write duplicate lines to HISTFILE at all
setopt HIST_VERIFY            # show an expanded history command before running it (e.g. !!, !123)
