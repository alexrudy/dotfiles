#!/usr/bin/env sh
set -eu

# shellcheck source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"

if ! command_exists fzf && ! test -f ~/.fzf.zsh && ! command_exists brew; then
    _process "🚛 install fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
    "${HOME}/.fzf/install" --bin --no-update-rc
    _finished "✅ fzf installed"
fi
