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
    # Its possible that pyenv didn't come from git.
    update_pyenv || true
fi

if [ -e "${HOME}/.pyenv" ]; then
    if [ ! -d "${HOME}/.pyenv/plugins/xxenv-latest" ]; then
        git clone https://github.com/momo-lab/xxenv-latest.git "${HOME}/.pyenv/plugins/xxenv-latest"
    fi
    if [ ! -d "${HOME}/.pyenv/plugins/pyenv-virtualenv" ]; then
        git clone https://github.com/pyenv/pyenv-virtualenv.git "${HOME}/.pyenv/plugins/pyenv-virtualenv"
    fi
fi

# setup pyenv so it works.

if ! command_exists pyenv ; then
    export PYENV="${HOME}/.pyenv/bin/pyenv"
else
    export PYENV="pyenv"
fi

PYTHON_VERSIONS=$(tr '\n' ' ' < "${DOTFILES}/python/python-versions.txt")

# shellcheck disable=SC2086
exec "$PYENV" install -s ${PYTHON_VERSIONS}
# shellcheck disable=SC2086
exec "$PYENV" global ${PYTHON_VERSIONS} system

_finished "✅ finished pyenv"
