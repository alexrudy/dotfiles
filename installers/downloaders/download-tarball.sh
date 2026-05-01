#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

download_tarball() {
    if ! command_exists curl; then
        if command_exists apt-get; then
            apt-get update -y
            apt-get install --no-install-recommends -y curl
        elif command_exists brew; then
            brew install curl
        else
            _message "🛑 can't find git or curl, aborting!"
            exit 1
        fi
    fi

    _process "🌍 downloading archive of ${GITHUB_REPO} from github and extracting"
    workdir="$(mktemp -d)"
    trap 'rm -rf "$workdir"' EXIT INT TERM
    tarball="${workdir}/dotfiles.tar.gz"

    curl -fsSL -o "$tarball" "https://github.com/${GITHUB_REPO}/tarball/${GIT_BRANCH}"
    mkdir -p "${DOTFILES}"
    tar -zxf "$tarball" --strip-components 1 -C "${DOTFILES}"

    rm -rf "$workdir"
    trap - EXIT INT TERM
    _finished "✅ ${DOTFILES} created, repository downloaded and extracted"
}

download_tarball
