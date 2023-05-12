#!/usr/bin/env sh
set -eu

# shellcheck source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"

download_git_clone() {
    if command_exists git; then
        _process "🐙 cloning ${GITHUB_REPO} from github"
        git clone "https://github.com/${GITHUB_REPO}.git" "${DOTFILES}"
    else
        exit 1
    fi
}

download_git_clone
