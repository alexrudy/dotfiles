#!/usr/bin/env sh

if ! [ -e "${HOME}/.pyenv" ]; then
    git clone https://github.com/pyenv/pyenv.git "${HOME}/.pyenv"
fi

if [ -e "${HOME}/.pyenv" ]; then
    if [ ! -d "${HOME}/.pyenv/plugins/xxenv-latest" ]; then
        git clone https://github.com/momo-lab/xxenv-latest.git "${HOME}/.pyenv/plugins/xxenv-latest"
    fi
    if [ ! -d "${HOME}/.pyenv/plugins/pyenv-virtualenv" ]; then
        git clone https://github.com/pyenv/pyenv-virtualenv.git "${HOME}/.pyenv/plugins/pyenv-virtualenv"
    fi
fi
