#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

download_git_pull() {
    if test -d "${DOTFILES}" ; then
        if command_exists git; then
            if git -C "$DOTFILES" pull > /dev/null 2>&1 ; then
                _message "🐙 Updated dotfiles git repo"
            else
                # Not a hard failure
                _message "⚠️  Failed to update git repo"
            fi
        fi
    else
        exit 1
    fi
}

download_git_pull
