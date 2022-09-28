if ! command_exists pyenv; then
    git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv
fi

if command_exists pyenv; then
    if [[ ! -d "$(pyenv root)/plugins/xxenv-latest" ]]; then
        git clone https://github.com/momo-lab/xxenv-latest.git "$(pyenv root)"/plugins/xxenv-latest
    fi
    if [[ ! -d "$(pyenv root)/plugins/pyenv-virtualenv" ]]; then
        git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
    fi
fi
