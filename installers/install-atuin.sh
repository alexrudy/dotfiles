#!/usr/bin/env sh
set -eu

# shellcheck source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"

if ! command_exists atuin; then
    _process "🐢 install atuin"
    if command_exists brew; then
        brew install atuin
    elif command_exists apt; then
        DEBIAN_FRONTEND=noninteractive
        export DEBIAN_FRONTEND
        LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/ellie/atuin/releases/latest)
        # Allow sed; sometimes it's more readable than ${variable//search/replace}
        # shellcheck disable=SC2001
        LATEST_VERSION=$(echo "$LATEST_RELEASE" | sed -e 's/.*"tag_name":"v\([^"]*\)".*/\1/')
        apt install "https://github.com/ellie/atuin/releases/download/v$LATEST_VERSION/atuin_${LATEST_VERSION}_amd64.deb"
    fi
    if command_exists atuin; then
        atuin import auto
    fi
    _message "✅ atuin installed"
fi
