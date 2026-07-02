#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

download_git_clone() {
    if command_exists git; then
        _process "🐙 cloning ${GITHUB_REPO} from github"
        git clone "https://github.com/${GITHUB_REPO}.git" "${DOTFILES}"
        # Fetch submodules separately and best-effort so a private one (e.g.
        # claude/private) that needs credentials can't abort the whole install.
        update_submodules_best_effort
    else
        exit 1
    fi
}

download_git_clone
