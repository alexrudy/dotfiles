#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"


if command_exists rbenv; then
    if [ ! -d "$(rbenv root)/plugins/xxenv-latest" ]; then
        _process "💎 install rbenv-latest"
        git clone https://github.com/momo-lab/xxenv-latest.git "$(rbenv root)/plugins/xxenv-latest"
        _finished "✅ installed rbenv-latest"
    fi
fi
