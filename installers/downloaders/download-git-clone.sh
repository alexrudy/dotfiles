#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

download_git_clone() {
    if command_exists git; then
        _process "🐙 cloning ${GITHUB_REPO} from github"
        git clone --recursive "https://github.com/${GITHUB_REPO}.git" "${DOTFILES}"
    else
        exit 1
    fi
}

download_git_clone
