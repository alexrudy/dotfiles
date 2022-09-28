#!/usr/bin/env sh
set -eu

# shellcheck source=installers/functions.sh
. "$(dirname "$0")/functions.sh"

if ! command_exists starship; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    _message "✅ starship installed"
fi
