#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

if ! command_exists starship; then
    _process "🚀 install starship"
    mkdir -p /tmp/dotfiles
    curl -sS https://starship.rs/install.sh | sh -s -- --yes > /tmp/dotfiles/starship.log 2>&1
    _finished "✅ starship installed"
fi
