#!/usr/bin/env sh
# shellcheck disable=SC3043
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

git_overlay() {
    if ! test -d "${DOTFILES}/.git"; then
        _process "🎛️  Adding git repository overlay"
        git init --quiet
        git remote add origin "https://github.com/${GITHUB_REPO}/"
        git fetch --quiet
        git checkout --quiet -ft "origin/${GIT_BRANCH}"
        _finished "✅ Converted ${DOTFILES} to a git repository"
    fi
}

git_overlay
