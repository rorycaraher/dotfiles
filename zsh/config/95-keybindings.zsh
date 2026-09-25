# use emacs-style keybindings as the base
bindkey -e

# history search: type a prefix, press up/down to filter history by it
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search

# forward-delete; zsh's emacs keymap leaves it unbound, so the terminal's escape sequence prints as ~
bindkey "^[[3~" delete-char
