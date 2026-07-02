#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

download_git_pull() {
    if test -d "${DOTFILES}" ; then
        if command_exists git; then
            _message "🐙 Pull latest dotfiles from github"
            if GIT_TERMINAL_PROMPT=0 git -C "$DOTFILES" pull --quiet --recurse-submodules > /dev/null 2>&1 ; then
                _message "🐙 Updated dotfiles git repo"
            else
                # Not a hard failure
                _message "⚠️  Failed to update git repo"
            fi
            # Fetch/init any submodule not yet checked out — e.g. a private one
            # skipped on a credential-less first install. Best-effort, never fatal.
            update_submodules_best_effort
        fi
    else
        exit 1
    fi
}

download_git_pull
