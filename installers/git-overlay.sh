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

        # Stitch git on top of the existing working tree without disturbing
        # it. The previous implementation used `git checkout -ft origin/main`
        # which silently discarded any local edits to tarball-extracted
        # files. Instead, point HEAD/index at origin/${GIT_BRANCH} via
        # plumbing commands and leave the working tree alone — git status
        # will then surface any drift between the working tree and remote.
        git update-ref "refs/heads/${GIT_BRANCH}" "$(git rev-parse "origin/${GIT_BRANCH}")"
        git symbolic-ref HEAD "refs/heads/${GIT_BRANCH}"
        git read-tree HEAD
        git branch --set-upstream-to="origin/${GIT_BRANCH}" "${GIT_BRANCH}" --quiet 2>/dev/null || true

        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
            _message "⚠️  working tree differs from origin/${GIT_BRANCH} — local edits preserved"
        fi

        _finished "✅ Converted ${DOTFILES} to a git repository"
    fi
}

git_overlay
