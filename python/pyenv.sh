if test -d "$HOME/.pyenv" ; then
    export PYENV_ROOT="$HOME/.pyenv"
    pathadd "$PYENV_ROOT/bin"

    eval "$(pyenv init --path)"
    if command_exists pyenv-virtualenv-init; then
        eval "$(pyenv virtualenv-init -)"
    fi
fi
