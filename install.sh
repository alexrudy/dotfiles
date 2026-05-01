#!/bin/sh
# shellcheck disable=SC3043,SC2218
set -eu

##################################
# install.sh is a GENERATED FILE #
##################################

# All changes should be made to installers/install.sh
# and included files therin, as the root one is compiled

# Tells the configuration to not worry
# that it might not find a dotfiles directory, and
# that it should make one instead.
export DOTFILES_INSTALLER=1

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
        if test "${DOTFILES}" = "${HOME}"; then
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

  if [ -t 1  ]; then
    printf "$(_spacer)$(tput setaf "$color")%s$(tput sgr0)\n" "$message" 2> /dev/null
  else
    printf "$(_spacer)%s\n" "$message" 2> /dev/null
  fi
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

# Stack of in-flight _process messages. Separator "|||" is unlikely to
# appear in human-written step labels. Lets nested _process/_finished
# pairs survive without each _finished clobbering an outer trap.
_PROCESS_STACK="${_PROCESS_STACK:-}"

_process_stack_push() {
  if [ -z "$_PROCESS_STACK" ]; then
    _PROCESS_STACK="$1"
  else
    _PROCESS_STACK="${_PROCESS_STACK}|||$1"
  fi
}

_process_stack_pop() {
  case "$_PROCESS_STACK" in
    *"|||"*) _PROCESS_STACK="${_PROCESS_STACK%|||*}" ;;
    *)       _PROCESS_STACK="" ;;
  esac
}

_process_stack_top() {
  case "$_PROCESS_STACK" in
    *"|||"*) printf '%s' "${_PROCESS_STACK##*|||}" ;;
    *)       printf '%s' "$_PROCESS_STACK" ;;
  esac
}

_process() {
  message="$*"
  _log "start(${LEVEL})" "$message"
  _print "$message" "7"
  LEVEL=$(( LEVEL + 1))
  _process_stack_push "$message"
  # The trap evaluates _process_stack_top at fire-time, so it always
  # reports the innermost in-flight step rather than a captured-once value.
  trap '_cleanup "$(_process_stack_top)"' EXIT
}

_finished() {
  message="$*"
  LEVEL=$(( LEVEL - 1))
  color=$(_color_code "$message")
  _log "finish(${LEVEL})" "$message"
  _print "$message" "$color"
  _process_stack_pop
  if [ -z "$_PROCESS_STACK" ]; then
    trap - EXIT
  fi
}

_error() {
  message="$*"
  LEVEL=$(( LEVEL - 1))
  _log "error" "$message"
  _print "$message" "1"
}

_cleanup() {
  _log "error" "$1"
  _print "⛔️ Install step $1 encountered an error" "1"
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

_sha256() {
    if command_exists sha256sum; then
        sha256sum "$1" | awk '{print $1}'
    elif command_exists shasum; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        return 1
    fi
}

# Atomically download a URL to a destination, optionally verifying sha256.
# Empty sha256 skips verification (use only when checksum is unknown).
# Usage: _download_verified URL DEST [SHA256]
_download_verified() {
    _dv_url="$1"
    _dv_dest="$2"
    _dv_sha256="${3:-}"

    _dv_tmp="$(mktemp)"
    if ! curl -fsSL --retry 3 --retry-delay 2 -o "$_dv_tmp" "$_dv_url"; then
        rm -f "$_dv_tmp"
        _message "⛔️ download failed: $_dv_url"
        return 1
    fi

    if [ -n "$_dv_sha256" ]; then
        _dv_actual="$(_sha256 "$_dv_tmp" || echo "")"
        if [ "$_dv_actual" != "$_dv_sha256" ]; then
            rm -f "$_dv_tmp"
            _message "⛔️ checksum mismatch for ${_dv_url}: expected ${_dv_sha256}, got ${_dv_actual}"
            return 1
        fi
    else
        _debug "no checksum supplied for ${_dv_url}"
    fi

    mkdir -p "$(dirname "$_dv_dest")"
    mv "$_dv_tmp" "$_dv_dest"
}

# Download a remote install script and run it via the given interpreter
# (default: sh). Fails loudly on HTTP error instead of piping a 404 page
# to the shell. Extra args after the interpreter pass through to the script.
# Usage: _run_install_script URL [INTERPRETER [SCRIPT_ARGS...]]
_run_install_script() {
    _ris_url="$1"
    _ris_shell="${2:-sh}"
    shift
    if [ $# -gt 0 ]; then shift; fi

    _ris_tmp="$(mktemp)"
    if ! curl -fsSL --retry 3 --retry-delay 2 -o "$_ris_tmp" "$_ris_url"; then
        rm -f "$_ris_tmp"
        _message "⛔️ download failed: $_ris_url"
        return 1
    fi

    "$_ris_shell" "$_ris_tmp" "$@"
    _ris_rc=$?
    rm -f "$_ris_tmp"
    return $_ris_rc
}
# END included from installers/functions.sh

# BEGIN included from installers/versions.sh

# Pinned versions and (optional) sha256 checksums for tools downloaded by
# installers. Empty checksum skips verification — fill in when known.
# To get a checksum: `curl -fsSL <url> | sha256sum` (or `shasum -a 256` on mac).

# ripgrep: https://github.com/BurntSushi/ripgrep/releases
RIPGREP_VERSION="14.1.1"
RIPGREP_SHA256_AMD64=""

# buf: https://github.com/bufbuild/buf/releases
BUF_VERSION="1.57.0"
BUF_SHA256_LINUX_X86_64=""
BUF_SHA256_LINUX_AARCH64=""
BUF_SHA256_DARWIN_X86_64=""
BUF_SHA256_DARWIN_ARM64=""

# buildifier: https://github.com/bazelbuild/buildtools/releases
BUILDIFIER_VERSION="6.3.3"
BUILDIFIER_SHA256_LINUX_AMD64=""
# END included from installers/versions.sh
# END included from installers/prelude.sh

install_dotfiles() {
    _log_init "$0"

    # BEGIN included from installers/download.sh

    download_dotfiles() {
        _process "📦 Acquiring Dotfiles"
       if test -d "${DOTFILES}/.git" ; then

            # BEGIN included from installers/downloaders/download-git-pull.sh

            # Already included installers/prelude.sh
            # shellcheck source=installers/prelude.sh

            download_git_pull() {
                if test -d "${DOTFILES}" ; then
                    if command_exists git; then
                        _message "🐙 Pull latest dotfiles from github"
                        if git -C "$DOTFILES" pull --quiet --recurse-submodules > /dev/null 2>&1 ; then
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
            _finished "✅ ${DOTFILES} exists."
       else
           if command_exists git; then

                # BEGIN included from installers/downloaders/download-git-clone.sh

                # Already included installers/prelude.sh
                # shellcheck source=installers/prelude.sh

                download_git_clone() {
                    if command_exists git; then
                        _process "🐙 cloning ${GITHUB_REPO} from github"
                        git clone --recursive "https://github.com/${GITHUB_REPO}.git" "${DOTFILES}"
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

                # Already included installers/prelude.sh
                # shellcheck source=installers/prelude.sh

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

        export DOWNLOAD=1

         # Already included installers/configure.sh
              # source=installers/configure.sh

         # Already included installers/prelude.sh
              # shellcheck source=installers/prelude.sh

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
}

install_dotfiles "$@"
