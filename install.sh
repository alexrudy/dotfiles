#!/bin/sh
# shellcheck disable=SC3043
set -eu

##################################
# install.sh is a GENERATED FILE #
##################################

# All changes should be made to installers/install.sh
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



# BEGIN included from installers/download.sh


GITHUB_REPO="${GITHUB_REPO:-alexrudy/dotfiles}"

DOTFILES="${DOTFILES:-${HOME}/.dotfiles/}"
if [ "$DOTFILES" = "/" ]; then
    DOTFILES="${HOME}/.dotfiles/"
fi


# BEGIN included from installers/functions.sh


# Library of functions useful for installing.
# Everything here should be POSIX sh

LOGFILE="${LOGFILE:-${HOME}/.dotfiles-install.log}"

LEVEL=${LEVEL:-0}

_spacer() {
    spacer=""

    j=0
    while [ $j -le "$LEVEL" ]; do
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

_message() {
  local message color
  message="$*"
  color=$(_color_code "$message")
  _log "debug" "$message"
  printf "$(_spacer) $(tput setaf "$color") %s $(tput sgr0)\n" "$message"
}

_process() {
  message="$*"
  _log "start" "$message"
  printf "$(_spacer)$(tput setaf 6)%s...$(tput sgr0)\n" "$message"
  LEVEL=$(( LEVEL + 1))
}

_finished() {
  message="$*"
  LEVEL=$(( LEVEL - 1))
  color=$(_color_code "$message")
  _log "finish" "$message"
  printf "$(_spacer)  $(tput setaf "$color")%s$(tput sgr0)\n" "$message"
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


download_dotfiles() {
    _process "📦 Acquiring Dotfiles"
   if test -d "${DOTFILES}" ; then

        # BEGIN included from installers/downloaders/download-git-pull.sh


        # Already included installers/functions.sh
        # shellcheck source=installers/functions.sh


        download_git_pull() {
            if test -d "${DOTFILES}" ; then
                if command_exists git; then
                    if git -C "$DOTFILES" pull > /dev/null 2>&1 ; then
                        _message "🐙 updated git repo"
                    else
                        # Not a hard failure
                        _message "⚠️  failed to update git repo"
                    fi
                fi
            else
                exit 1
            fi
        }

        download_git_pull

        # END included from installers/downloaders/download-git-pull.sh

        _finished "✅ ${DOTFILES} exists."
   else
       if command_exists git; then

            # BEGIN included from installers/downloaders/download-git-clone.sh


            # Already included installers/functions.sh
            # shellcheck source=installers/functions.sh


            download_git_clone() {
                if command_exists git; then
                    _process "🐙 cloning ${GITHUB_REPO} from github"
                    git clone "https://github.com/${GITHUB_REPO}.git" "${DOTFILES}"
                else
                    exit 1
                fi
            }

            download_git_clone

            # END included from installers/downloaders/download-git-clone.sh

            _finished "✅ ${DOTFILES} cloned"
       else
            _message "⚠️  command git not found - falling back to tarball"

            # BEGIN included from installers/downloaders/download-tarball.sh


            # Already included installers/functions.sh
            # shellcheck source=installers/functions.sh


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

            # END included from installers/downloaders/download-tarball.sh

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

# END included from installers/download.sh


# This does not get literally included, so that running an old copy of `install.sh`
# will effectively self-update, grabbing the latest version from here.
# shellcheck source=installers/installer.sh # no-include
. "${DOTFILES}/installers/installer.sh"
