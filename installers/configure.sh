#!/usr/bin/env sh
# shellcheck disable=SC3043
set -eu

# Initialize DOTFILES and related configuration variables
GITHUB_REPO="${GITHUB_REPO:-alexrudy/dotfiles}"
GIT_BRANCH="main"
export GITHUB_REPO GIT_BRANCH

DOWNLOAD=${DOWNLOAD:-}

DOTFILES="${DOTFILES:-${HOME}/.dotfiles/}"
if [ "$DOTFILES" = "/" ]; then
    DOTFILES="${HOME}/.dotfiles/"
fi

if test -z "${DOWNLOAD}"; then
    if ! test -d "${DOTFILES}"; then
        DOTFILES=$(readlink -f "$(dirname "$0")")
        export DOTFILES
    fi
fi

NONINTERACTIVE=1
export NONINTERACTIVE

DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

TERM="${TERM:-dumb}"
export TERM

if test -z "${DOWNLOAD}"; then
    cd "${DOTFILES}"
fi
