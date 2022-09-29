#!/usr/bin/env sh
set -eu

# shellcheck source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"

_process "🚛 install fzf"
if ! command_exists fzf && ! test -f ~/.fzf.zsh && ! command_exists brew; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
    "${HOME}/.fzf/install" --bin --no-update-rc
    _finished "✅ fzf installed"
else
    _finished "✅ fzf already installed"
fi
