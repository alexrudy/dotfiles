#!/bin/sh
set -eu

DOTFILES=$(readlink -f "$(dirname "$0")")
export DOTFILES

cd "${DOTFILES}"
sh "${DOTFILES}/installers/installer.sh"
