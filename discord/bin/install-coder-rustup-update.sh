#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

CODER_USERNAME=${CODER_USERNAME:-}
CODER=${CODER:-}
if test -z "$CODER_USERNAME" && test -z "$CODER"; then
    exit 0
fi

if ! command_exists rustup; then
    _debug "⏭  rustup not installed, skipping update"
    exit 0
fi

_process "🦀 rustup update"
rustup update
_finished "✅ rustup updated"
