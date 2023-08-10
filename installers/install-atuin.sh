#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

install_atuin() {
    if ! command_exists atuin; then
        _process "🐢 install atuin"
        if command_exists brew; then
            # This should be a no-op if atuin is already installed
            brew install atuin
        elif command_exists cargo; then
            # Add me back when sparse registries stabilize
            # CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
            # export CARGO_REGISTRIES_CRATES_IO_PROTOCOL
            cargo install atuin
        else
            curl https://raw.githubusercontent.com/ellie/atuin/main/install.sh | bash
        fi

        if command_exists atuin; then
            export HISTFILE="${HISTFILE:-${HOME}/.zsh_history}"
            atuin import auto
            _finished "✅ atuin installed"
        else
            _finished "❌ atuin not installed"
        fi
    fi
}

install_atuin
