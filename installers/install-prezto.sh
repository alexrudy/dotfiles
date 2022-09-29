#!/usr/bin/env sh
set -eu

# shellcheck source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"

ZPREZTO="${ZDOTDIR:-$HOME}/.zprezto"

if ! test -e "$ZPREZTO"; then
    _process "⛽️ install zprezto"
    git clone --recursive https://github.com/sorin-ionescu/prezto.git
    _finished "✅ prezto installed"
else
    _process "🚛 update zprezto"
    _=$(git -C "${ZPREZTO}" pull)
    _=$(git -C "${ZPREZTO}" submodule sync --recursive)
    _=$(git -C "${ZPREZTO}" submodule update --init --recursive)
    _finished "✅ prezto updated"
fi

if ! test -e "${ZPREZTO}/contrib/fzf-tab"; then
    _process "📟 install fzf-tab"
    git clone https://github.com/Aloxaf/fzf-tab "${ZPREZTO}/.zprezto/contrib/fzf-tab"
    _finished "✅ fzf-tab installed"
fi
