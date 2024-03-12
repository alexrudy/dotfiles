#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

install_talon() {

    TALON="${DOTFILES}/talon/talon.dir/user"

    _process "🎤 Update talon scripts"
    git -C "${DOTFILES}" submodule update --init --recursive -- "${TALON}"
    _finished "✅ Updated talon scripts"

}

install_talon
