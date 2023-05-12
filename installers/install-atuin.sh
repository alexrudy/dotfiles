#!/usr/bin/env sh
set -eu

# shellcheck source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"

install_atuin() {
    if ! command_exists atuin; then
        _process "🐢 install atuin"
        if command_exists brew; then
            # This should be a no-op if atuin is already installed
            brew install atuin
        elif command_exists cargo; then
            cargo install atuin
        fi
        if command_exists atuin; then
            atuin import auto
        fi
        _message "✅ atuin installed"
    fi
}

install_atuin
