#!/bin/sh
# shellcheck disable=SC3043
set -eu

# shellcheck source=installers/configure.sh
. "${DOTFILES}/installers/configure.sh"

# shellcheck source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"


if ! test -d "${DOTFILES}/.git"; then
    # shellcheck source=installers/git-overlay.sh
    . "${DOTFILES}/installers/git-overlay.sh"
fi

# shellcheck source=installers/downloaders/download-git-pull.sh
. "${DOTFILES}/installers/downloaders/download-git-pull.sh"

# shellcheck source=installers/installer.sh # no-include
. "${DOTFILES}/installers/installer.sh"
