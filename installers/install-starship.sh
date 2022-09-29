#!/usr/bin/env sh
set -eu

# shellcheck source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"

if ! command_exists starship; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    _message "✅ starship installed"
fi
