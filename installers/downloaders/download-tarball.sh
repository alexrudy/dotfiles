#!/usr/bin/env sh
set -eu

# shellcheck source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"

download_tarball() {
    if ! command_exists curl; then
        if command_exists apt-get; then
            apt-get update -y
            apt-get install --no-install-recommends -y curl
        else
            _message "🛑 can't find git or curl, aborting!"
            exit 1
        fi
    fi

    _process "🌍 downloading archive of ${GITHUB_REPO} from github and extracting"
    curl -fsLo /tmp/dotfiles.tar.gz "https://github.com/${GITHUB_REPO}/tarball/main"
    mkdir -p "${DOTFILES}"
    tar -zxf /tmp/dotfiles.tar.gz --strip-components 1 -C "${DOTFILES}"
    rm -rf /tmp/dotfiles.tar.gz
    _finished "✅ ${DOTFILES} created, repository downloaded and extracted"
}

download_tarball
