#!/usr/bin/env sh
# shellcheck disable=SC3043
set -eu

# Resolve a path's absolute, canonical form (following all symlinks).
# Picks one backend at source-time and binds _realpath to it. `readlink -f`
# is GNU-only and was absent from macOS until 12 (Monterey) — falling back
# through realpath / python3 / perl covers older macOS, BSDs, and minimal
# Linux containers. Last-resort echo preserves callers that compare the
# result against another path resolved the same way.
if command -v greadlink >/dev/null 2>&1; then
    _realpath() { greadlink -f -- "$1"; }
elif readlink -f -- / >/dev/null 2>&1; then
    _realpath() { readlink -f -- "$1"; }
elif command -v realpath >/dev/null 2>&1; then
    _realpath() { realpath -- "$1"; }
elif command -v python3 >/dev/null 2>&1; then
    _realpath() { python3 -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' "$1"; }
elif command -v perl >/dev/null 2>&1; then
    _realpath() { perl -MCwd -e 'print Cwd::abs_path($ARGV[0]),"\n"' "$1"; }
else
    _realpath() { printf '%s\n' "$1"; }
fi

# Initialize DOTFILES and related configuration variables
GITHUB_REPO="${GITHUB_REPO:-alexrudy/dotfiles}"
GIT_BRANCH="main"
export GITHUB_REPO GIT_BRANCH

DOTFILES_INSTALLER=${DOTFILES_INSTALLER:-}

DOTFILES="${DOTFILES:-${HOME}/.dotfiles/}"
if [ "$DOTFILES" = "/" ]; then
    DOTFILES="${HOME}/.dotfiles/"
fi

if test -z "${DOTFILES_INSTALLER}"; then
    if ! test -d "${DOTFILES}"; then
        DOTFILES=$(_realpath "$(dirname "$0")")
        if test "${DOTFILES}" = "${HOME}"; then
            echo "ERROR: DOTFILES cannot be found."
            exit 1
        fi
        export DOTFILES
    fi
fi

NONINTERACTIVE=1
export NONINTERACTIVE

DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

TERM="${TERM:-dumb}"
export TERM

if test -z "${DOTFILES_INSTALLER}"; then
    cd "${DOTFILES}"
fi
