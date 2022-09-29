#!/bin/sh
# shellcheck disable=SC3043
set -eu

DOTFILES=$(readlink -f "$(dirname "$0")")
export DOTFILES

cd "${DOTFILES}"

# source=installers/installer.sh
. "${DOTFILES}/installers/installer.sh"

echo "🍾 Installation finshed - you might want to run '. \"\$HOME/.zshrc\"'"
