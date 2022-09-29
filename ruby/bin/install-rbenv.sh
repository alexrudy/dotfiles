#!/usr/bin/env sh

if command_exists rbenv; then
    if [ ! -d "$(rbenv root)/plugins/xxenv-latest" ]; then
        git clone https://github.com/momo-lab/xxenv-latest.git "$(rbenv root)/plugins/xxenv-latest"
    fi
fi
