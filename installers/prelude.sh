#!/usr/bin/env sh
# shellcheck disable=SC3043
set -eu

# Prelude which includes necessary scripts for the dotfiles installer to run

# shellcheck source=installers/configure.sh
. "${DOTFILES}/installers/configure.sh"

# shellcheck source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"
