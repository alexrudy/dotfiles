#!/bin/sh
# shellcheck disable=SC3043
set -eu

# Tells the configuration to not worry
# that it might not find a dotfiles directory, and
# that it should make one instead.
export DOTFILES_INSTALLER=1

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

install_dotfiles() {
    _log_init "$0"

    # shellcheck source=installers/download.sh
    . "${DOTFILES}/installers/download.sh"

    # This does not get literally included, so that running an old copy of `install.sh`
    # will effectively self-update, grabbing the latest version from here.
    # shellcheck source=installers/installer.sh # no-include
    . "${DOTFILES}/installers/installer.sh"
}

install_dotfiles "$@"
