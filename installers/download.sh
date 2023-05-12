#!/usr/bin/env sh
# shellcheck disable=SC3043
set -eu

# source=installers/configure.sh
. "${DOTFILES}/installers/configure.sh"

# shellcheck source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"

download_dotfiles() {
    _process "📦 Acquiring Dotfiles"
   if test -d "${DOTFILES}" ; then
        # shellcheck source=installers/downloaders/download-git-pull.sh
        . "${DOTFILES}/installers/downloaders/download-git-pull.sh"
        _finished "✅ ${DOTFILES} exists."
   else
       if command_exists git; then
            # shellcheck source=installers/downloaders/download-git-clone.sh
            . "${DOTFILES}/installers/downloaders/download-git-clone.sh"
            _finished "✅ ${DOTFILES} cloned"
       else
            _message "⚠️  command git not found - falling back to tarball"
            # shellcheck source=installers/downloaders/download-tarball.sh
            . "${DOTFILES}/installers/downloaders/download-tarball.sh"
            _finished "✅ ${DOTFILES} downloaded."
       fi;
   fi;
}


download() {
    echo "$(date) [dotfiles] $0 $*" > "$LOGFILE"
    echo "$(date) [dotfiles] installing in ${DOTFILES}" >> "$LOGFILE"

    _process "🌐  Downloading dotfiles to ${DOTFILES}'"
    download_dotfiles
    _finished "✅ ${DOTFILES} created, repository downloaded and extracted"

}

download "$@"
