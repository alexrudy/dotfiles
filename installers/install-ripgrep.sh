#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

install_ripgrep() {
    if ! command_exists ripgrep; then
        if command_exists dpkg && command_exists curl; then
            _process "🏄 Install ripgrep"
            curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
            sudo dpkg -i ripgrep_13.0.0_amd64.deb
            _finished "✅ Installed ripgrep"
        fi

        if command_exists brew; then
            brew install ripgrep
        fi
    fi
}

install_ripgrep
