#!/bin/sh
# shellcheck disable=SC3043
set -eu

# source=installers/configure.sh
. "${DOTFILES}/installers/configure.sh"

# source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"

_log_init "$0"

# source=installers/download.sh
. "${DOTFILES}/installers/download.sh"

# This does not get literally included, so that running an old copy of `install.sh`
# will effectively self-update, grabbing the latest version from here.
# shellcheck source=installers/installer.sh # no-include
. "${DOTFILES}/installers/installer.sh"
