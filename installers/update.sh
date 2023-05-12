#!/bin/sh
# shellcheck disable=SC3043
set -eu

###################################
# /update.sh is a GENERATED FILE #
###################################

# All changes should be made to /installers/install.sh
# and included files therin, as the root one is compiled


# shellcheck source=installers/configure.sh
. "${DOTFILES}/installers/configure.sh"

# shellcheck source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"


if ! test -d "${DOTFILES}/.git"; then
    _message "⛔️ ${DOTFILES} does not appear to be a git repo"
    exit 2
fi

# shellcheck source=installers/git-overlay.sh
. "${DOTFILES}/installers/git-overlay.sh"

# shellcheck source=installers/installer.sh # no-include
. "${DOTFILES}/installers/installer.sh"
