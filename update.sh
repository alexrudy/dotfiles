#!/bin/sh
# shellcheck disable=SC3043
set -eu

#################################
# update.sh is a GENERATED FILE #
#################################

# All changes should be made to installers/update.sh
# and included files therin, as the root one is compiled

export DOTFILES_INSTALLER=""

# BEGIN included from installers/prelude.sh

# Prelude which includes necessary scripts for the dotfiles installer to run

# BEGIN included from installers/configure.sh

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
        DOTFILES=$(readlink -f "$(dirname "$0")")
        if test "${DOTFILES}" -eq "${HOME}"; then
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
# END included from installers/configure.sh

# BEGIN included from installers/functions.sh

# Library of functions useful for installing.
# Everything here should be POSIX sh

# Allow shellcheck to ignore unused functions

LOGFILE="${LOGFILE:-${HOME}/.dotfiles-install.log}"

LEVEL=${LEVEL:-0}
DEBUG=${DEBUG:-0}

_spacer() {
    spacer=""

    j=0
    while [ $j -lt "$LEVEL" ]; do
      spacer="$spacer  "
      j=$(( j + 1 ))
    done

    echo "$spacer"
}

_log_timestamp() {
    date +%H:%M:%S
}

_log_init() {
    printf "$(_log_timestamp) [%-10.10s]: %s\n" "init" "$1" > "$LOGFILE"
    printf "$(_log_timestamp) [%-10.10s]: %s\n" "init" "$(date)" >> "$LOGFILE"
    printf "$(_log_timestamp) [%-10.10s]: %s\n" "init" "installing in ${DOTFILES}" >> "$LOGFILE"

}

_log() {
  local message
  message=$(echo "$2" | perl -pe's/[[:space:]]*[[:^ascii:]]+[[:space:]]*//' )
  printf "$(_log_timestamp) [%-10.10s]: %s\n" "$1" "${message}" >> "$LOGFILE"
}

_print() {
  local message color
  message="$1"
  color="$2"

  # if [ -t 0 ] && [ -t 1  ]; then
  #   printf "$(_spacer)$(tput setaf "$color")%s$(tput sgr0)\n" "$message"
  # else
    printf "$(_spacer)%s\n" "$message"
  # fi
}

_debug() {
  local message color
  message="$*"
  _log "debug" "$message"
  if [ "$DEBUG" -eq "1" ]; then
    _print "$message" "4"
  fi
}

_message() {
  local message color
  message="$*"
  color=$(_color_code "$message")
  _log "debug" "$message"
  _print "$message" "7"
}

_process() {
  message="$*"
  _log "start(${LEVEL})" "$message"
  _print "$message" "7"
  LEVEL=$(( LEVEL + 1))
  trap '_cleanup "$message"' EXIT
}

_finished() {
  message="$*"
  LEVEL=$(( LEVEL - 1))
  color=$(_color_code "$message")
  _log "finish(${LEVEL})" "$message"
  _print "$message" "$color"
  trap - EXIT
}

_error() {
  message="$*"
  LEVEL=$(( LEVEL - 1))
  _log "error" "$message"
  _print "$message" "1"
}

_cleanup() {
  _error "⛔️ Install step $1 encountered an error"
}

_color_code() {
    case "$*" in
        ✅*)
            echo 2;;
        ⚠️*)
            echo 3;;
        ⛔️*)
            echo 1;;
        ❌*)
            echo 1;;
        *)
            echo 7;;
    esac
}

command_exists () {
    type "$1" > /dev/null 2>&1
}
# END included from installers/functions.sh
# END included from installers/prelude.sh

update () {
    _log_init "$0"

    if ! test -d "${DOTFILES}/.git"; then

        # BEGIN included from installers/git-overlay.sh

        # Already included installers/prelude.sh
        # shellcheck source=installers/prelude.sh

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

    # Already included installers/prelude.sh
    # shellcheck source=installers/prelude.sh

    download_git_pull() {
        if test -d "${DOTFILES}" ; then
            if command_exists git; then
                _message "🐙 Pull latest dotfiles from github"
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

}

update "$@"
