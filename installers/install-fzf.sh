#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

# Update an existing standalone clone unconditionally — if it's there, the
# user owns it and wants it kept current. The clone-from-scratch path only
# runs when fzf is otherwise unavailable (no fzf binary, no completion
# script, no brew to install it elsewhere).
if test -d "${HOME}/.fzf/.git"; then
    _process "🔄 update fzf"
    git -C "${HOME}/.fzf" pull --quiet > /dev/null 2>&1 || \
        _message "⚠️  fzf: git pull failed, leaving as-is"
    "${HOME}/.fzf/install" --bin --no-update-rc > /dev/null
    _finished "✅ fzf updated"
elif ! command_exists fzf && ! command_exists brew; then
    _process "🚛 install fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
    "${HOME}/.fzf/install" --bin --no-update-rc
    _finished "✅ fzf installed"
fi
