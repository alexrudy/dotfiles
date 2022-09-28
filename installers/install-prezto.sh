#!/usr/bin/env sh
set -eu

# shellcheck source=installers/functions.sh
. "$(dirname "$0")/functions.sh"

if ! test -e "${ZDOTDIR:-$HOME}/.zprezto"; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    _message "✅ prezto installed"
fi

if ! test -e "${ZDOTDIR:-$HOME}/.zprezto/contrib/fzf-tab"; then
    git clone https://github.com/Aloxaf/fzf-tab "${ZDOTDIR:-$HOME}/.zprezto/contrib/fzf-tab"
    _message "✅ fzf-tab installed"
fi
