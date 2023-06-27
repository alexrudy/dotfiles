#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

update_pyenv() {
    cd "${HOME}/.pyenv" 
    (git pull) > /dev/null
    cd - > /dev/null
}

_process "🐍 pyenv"
if ! [ -e "${HOME}/.pyenv" ]; then
    git clone https://github.com/pyenv/pyenv.git "${HOME}/.pyenv"
else
    update_pyenv
fi

if [ -e "${HOME}/.pyenv" ]; then
    if [ ! -d "${HOME}/.pyenv/plugins/xxenv-latest" ]; then
        git clone https://github.com/momo-lab/xxenv-latest.git "${HOME}/.pyenv/plugins/xxenv-latest"
    fi
    if [ ! -d "${HOME}/.pyenv/plugins/pyenv-virtualenv" ]; then
        git clone https://github.com/pyenv/pyenv-virtualenv.git "${HOME}/.pyenv/plugins/pyenv-virtualenv"
    fi
fi

pyenv install -s $(cat "${DOTFILES}/python/python-versions.txt")
pyenv global $(cat "${DOTFILES}/python/python-versions.txt") system
_finished "✅ finished pyenv"