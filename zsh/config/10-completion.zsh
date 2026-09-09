autoload -Uz compinit && compinit

# case-insensitive, and substring/partial-word matching
# ('zs' -> zsh / zsh-private, 'bat' -> 20-bat.zsh)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# highlighted, arrow-navigable menu instead of a plain list
zstyle ':completion:*' menu select

# clearer output when there are many matches or none
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
