fpath=($DOTFILES/domino/functions $fpath)
autoload -U $DOTFILES/domino/functions/*(:t)

alias domino.s='sync.py -c .domino.yml'