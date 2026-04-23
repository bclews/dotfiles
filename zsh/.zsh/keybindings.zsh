# Prefix-matched history search on arrow keys:
# type "g" and press Up to find the most recent command starting with "g".
# The widgets are built into zsh; OMZ used to bind them by default.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# CSI sequences (normal) and SS3 sequences (application keypad mode).
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search
