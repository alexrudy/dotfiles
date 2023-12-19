if test -d "$HOME/.pyenv" ; then
    export PYENV_ROOT="$HOME/.pyenv"
    pathadd "$PYENV_ROOT/bin"

    eval "$(pyenv init --path)"
    if command_exists pyenv-virtualenv-init; then
        eval "$(pyenv virtualenv-init -)"
    fi

    if pyenv whence pipx > /dev/null 2>&1; then
        PIPX_VERSION=$(pyenv whence pipx | tail -n 1)

        alias pipx="${PYENV_ROOT}/versions/${PIPX_VERSION}/bin/pipx"
    fi
fi
