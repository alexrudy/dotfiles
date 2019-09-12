export PYTHONIOENCODING=UTF8
alias jnls='jupyter notebook list'

fpath=($DOTFILES/python/functions $fpath)
autoload -U $DOTFILES/python/functions/*(:t)
