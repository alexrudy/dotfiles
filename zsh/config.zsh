export CLICOLOR=1
export LESSCHARSET=utf-8

fpath=($DOTFILES/zsh/functions $fpath)
autoload -U $DOTFILES/zsh/functions/*(:t)
