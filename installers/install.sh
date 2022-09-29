#!/bin/sh
# shellcheck disable=SC3043
set -eu

###################################
# /install.sh is a GENERATED FILE #
###################################

# All changes should be made to /installers/install.sh
# and included files therin, as the root one is compiled


DOTFILES=$(readlink -f "$(dirname "$0")")
export DOTFILES

cd "${DOTFILES}"

# source=installers/download.sh
. "${DOTFILES}/installers/download.sh"

# This does not get literally included, so that running an old copy of `install.sh`
# will effectively self-update, grabbing the latest version from here.
# shellcheck source=installers/installer.sh # no-include
. "${DOTFILES}/installers/installer.sh"
