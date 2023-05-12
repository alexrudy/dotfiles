#!/bin/sh
# shellcheck disable=SC3043
set -eu

#################################
# update.sh is a GENERATED FILE #
#################################

# All changes should be made to installers/update.sh
# and included files therin, as the root one is compiled


# BEGIN included from installers/configure.sh


# Initialize DOTFILES and related configuration variables
GITHUB_REPO="${GITHUB_REPO:-alexrudy/dotfiles}"
GIT_BRANCH="main"
export GITHUB_REPO GIT_BRANCH

DOTFILES="${DOTFILES:-${HOME}/.dotfiles/}"
if [ "$DOTFILES" = "/" ]; then
    DOTFILES="${HOME}/.dotfiles/"
fi

if ! test -d "${DOTFILES}"; then
    DOTFILES=$(readlink -f "$(dirname "$0")")
    export DOTFILES
fi

NONINTERACTIVE=1
export NONINTERACTIVE

DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

TERM="${TERM:-dumb}"
export TERM

cd "${DOTFILES}"

# END included from installers/configure.sh



# BEGIN included from installers/functions.sh


# Library of functions useful for installing.
# Everything here should be POSIX sh

LOGFILE="${LOGFILE:-${HOME}/.dotfiles-install.log}"

LEVEL=${LEVEL:-0}

_spacer() {
    spacer=""

    j=0
    while [ $j -lt "$LEVEL" ]; do
      spacer="$spacer  "
      j=$(( j + 1 ))
    done

    echo "$spacer"
}

_log() {
  local message
  message=$(printf '%s' "$2" | cut -c 1)

  message="$(echo "$message" | xargs)"
  printf "$(date) [%-8.8s]: %s\n" "$1" "${message}" >> "$LOGFILE"
}

_print() {
  local message color
  message="$1"
  color="$2"
  printf "$(_spacer)$(tput setaf "$color")%s$(tput sgr0)\n" "$message"
}

_message() {
  local message color
  message="$*"
  color=$(_color_code "$message")
  _log "debug" "$message"
  _print "$message" "$color"
}

_process() {
  message="$*"
  _log "start" "$message"
  _print "$message" "7"
  LEVEL=$(( LEVEL + 1))
}

_finished() {
  message="$*"
  LEVEL=$(( LEVEL - 1))
  color=$(_color_code "$message")
  _log "finish" "$message"
  _print "$message" "$color"
}

_color_code() {
    case "$*" in
        ✅*)
            echo 2;;
        ⚠️*)
            echo 3;;
        ⛔️*)
            echo 1;;
        *)
            echo 7;;
    esac
}

command_exists () {
    type "$1" > /dev/null 2>&1
}

# END included from installers/functions.sh


if ! test -d "${DOTFILES}/.git"; then

    # BEGIN included from installers/git-overlay.sh


    # Already included installers/configure.sh
    # shellcheck source=installers/configure.sh


    # Already included installers/functions.sh
    # shellcheck source=installers/functions.sh


    git_overlay() {
        if ! test -d "${DOTFILES}/.git"; then
            _process "🎛️  Adding git repository overlay"
            git init --quiet
            git remote add origin "https://github.com/${GITHUB_REPO}/"
            git fetch --quiet
            git checkout --quiet -ft "origin/${GIT_BRANCH}"
            _finished "✅ Converted ${DOTFILES} to a git repository"
        fi
    }

    git_overlay

    # END included from installers/git-overlay.sh

fi


# BEGIN included from installers/downloaders/download-git-pull.sh


# Already included installers/functions.sh
# shellcheck source=installers/functions.sh


download_git_pull() {
    if test -d "${DOTFILES}" ; then
        if command_exists git; then
            if git -C "$DOTFILES" pull > /dev/null 2>&1 ; then
                _message "🐙 Updated dotfiles git repo"
            else
                # Not a hard failure
                _message "⚠️  Failed to update git repo"
            fi
        fi
    else
        exit 1
    fi
}

download_git_pull

# END included from installers/downloaders/download-git-pull.sh


# shellcheck source=installers/installer.sh # no-include
. "${DOTFILES}/installers/installer.sh"
