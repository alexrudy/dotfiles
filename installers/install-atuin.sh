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
        elif command_exists apt; then
            ATUIN_LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/ellie/atuin/releases/latest)
            # Allow sed; sometimes it's more readable than ${variable//search/replace}
            # shellcheck disable=SC2001
            ATUIN_LATEST_VERSION=$(echo "$ATUIN_LATEST_RELEASE" | sed -e 's/.*"tag_name":"v\([^"]*\)".*/\1/')
            apt install "https://github.com/ellie/atuin/releases/download/v$ATUIN_LATEST_VERSION/atuin_${ATUIN_LATEST_VERSION}_amd64.deb"
        fi
        if command_exists atuin; then
            atuin import auto
        fi
        _message "✅ atuin installed"
    fi
    exit 5
}

install_atuin
