#!/usr/bin/env sh
set -eu

if test -d "${HOME}/.dotfiles"; then
    sh "${HOME}/.dotfiles/update.sh"
else
    sh -c "$(curl -fsL https://raw.githubusercontent.com/alexrudy/dotfiles/main/install.sh)"
fi