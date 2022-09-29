#!/bin/sh
set -eu

DOTFILES=$(readlink -f "$(dirname "$0")")
export DOTFILES

cd "${DOTFILES}"
sh "${DOTFILES}/installers/installer.sh"

echo "🍾 Installation finshed - you might want to run '. \"\$HOME/.zshrc\"'"
