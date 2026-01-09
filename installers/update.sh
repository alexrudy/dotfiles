#!/bin/sh
# shellcheck disable=SC3043,SC2218
set -eu

export DOTFILES_INSTALLER=""

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

update () {
    _log_init "$0"

    if ! test -d "${DOTFILES}/.git"; then
        # shellcheck source=installers/git-overlay.sh
        . "${DOTFILES}/installers/git-overlay.sh"
    fi

    # shellcheck source=installers/downloaders/download-git-pull.sh
    . "${DOTFILES}/installers/downloaders/download-git-pull.sh"

    # shellcheck source=installers/installer.sh # no-include
    . "${DOTFILES}/installers/installer.sh"

}

update "$@"
