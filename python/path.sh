if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    pathadd "$PYENV_ROOT/bin"

    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

pathadd $DOTFILES/python/bin
pathadd $HOME/.local/bin

pathpromote $HOME/.local/bin