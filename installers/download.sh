#!/usr/bin/env sh
# shellcheck disable=SC3043
set -eu

GITHUB_REPO="${GITHUB_REPO:-alexrudy/dotfiles}"

DOTFILES="${DOTFILES:-${HOME}/.dotfiles/}"

# shellcheck source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"

download_dotfiles() {
    _process "📦 Acquiring Dotfiles"
   if test -d "${DOTFILES}" ; then
        if command_exists git; then
            if git -C "$DOTFILES" pull > /dev/null 2>&1 ; then
                _message "🐙 updated git repo"
            else
                _message "⚠️  failed to update git repo"
            fi
        fi
        _finished "✅ ${DOTFILES} exists. Skipping download."
   else
       if command_exists git; then
            _process "🐙 cloning ${GITHUB_REPO} from github"
            git clone "git@github.com/${GITHUB_REPO}.git" "${DOTFILES}"
            _finished "✅ ${DOTFILES} cloned"
       else
            _finished "⚠️  command git not found - falling back to tarball"
            _process "🌍 downloading archive of ${GITHUB_REPO} from github and extracting"
            curl -fsLo /tmp/dotfiles.tar.gz "https://github.com/${GITHUB_REPO}/tarball/main"
            mkdir -p "${DOTFILES}"
            tar -zxf /tmp/dotfiles.tar.gz --strip-components 1 -C "${DOTFILES}"
            rm -rf /tmp/dotfiles.tar.gz
            _finished "✅ ${DOTFILES} created, repository downloaded and extracted"
       fi;
   fi;
}

main() {
    echo "🌐  Downloading dotfiles to ${DOTFILES}'"


    echo "$(date) [dotfiles] $0 $*" > "$LOGFILE"
    echo "$(date) [dotfiles] installing in ${DOTFILES}" >> "$LOGFILE"

    download_dotfiles

}

main "$@"
