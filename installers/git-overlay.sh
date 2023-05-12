#!/usr/bin/env sh
# shellcheck disable=SC3043
set -eu

# shellcheck source=installers/configure.sh
. "${DOTFILES}/installers/configure.sh"

# shellcheck source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"

git_overlay() {
    _process "🎛️ Adding git repository overlay"
    git init --quiet
    git remote add origin "https://github.com/${GITHUB_REPO}/"
    git fetch --quiet
    git checkout --quiet -ft "origin/${GIT_BRANCH}"
    _finished "✅ Converted ${DOTFILES} to a git repository"
}

git_overlay
