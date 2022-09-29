#!/usr/bin/env sh

if ! [ -e "${HOME}/.pyenv" ]; then
    git clone https://github.com/pyenv/pyenv.git "${HOME}/.pyenv"
fi

# shellcheck source=core/functions.sh
. "${DOTFILES}/core/functions.sh"

# shellcheck source=python/pyenv.sh
. "${DOTFILES}/python/pyenv.sh"

if command_exists pyenv; then
    if [ ! -d "$(pyenv root)/plugins/xxenv-latest" ]; then
        git clone https://github.com/momo-lab/xxenv-latest.git "$(pyenv root)/plugins/xxenv-latest"
    fi
    if [ ! -d "$(pyenv root)/plugins/pyenv-virtualenv" ]; then
        git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)/plugins/pyenv-virtualenv"
    fi
fi
