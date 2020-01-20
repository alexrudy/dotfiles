if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    pathadd "$PYENV_ROOT/bin"
fi

if command_exists pyenv; then
    eval "$(pyenv init -)"
    if command_exists pyenv-virtualenv; then 
        eval "$(pyenv virtualenv-init -)"
    fi
fi
