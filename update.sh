#!/bin/sh
# shellcheck disable=SC3043,SC2218
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

# Resolve a path's absolute, canonical form (following all symlinks).
# Picks one backend at source-time and binds _realpath to it. `readlink -f`
# is GNU-only and was absent from macOS until 12 (Monterey) — falling back
# through realpath / python3 / perl covers older macOS, BSDs, and minimal
# Linux containers. Last-resort echo preserves callers that compare the
# result against another path resolved the same way.
if command -v greadlink >/dev/null 2>&1; then
    _realpath() { greadlink -f -- "$1"; }
elif readlink -f -- / >/dev/null 2>&1; then
    _realpath() { readlink -f -- "$1"; }
elif command -v realpath >/dev/null 2>&1; then
    _realpath() { realpath -- "$1"; }
elif command -v python3 >/dev/null 2>&1; then
    _realpath() { python3 -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' "$1"; }
elif command -v perl >/dev/null 2>&1; then
    _realpath() { perl -MCwd -e 'print Cwd::abs_path($ARGV[0]),"\n"' "$1"; }
else
    _realpath() { printf '%s\n' "$1"; }
fi

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
        DOTFILES=$(_realpath "$(dirname "$0")")
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

# Default log destination for apt_run. Overridable via env if a caller
# wants per-installer logs.
APT_LOG="${APT_LOG:-${HOME}/.dotfiles-apt.log}"

# Run a command (typically apt-get) silently, capturing stdout+stderr into
# $APT_LOG with a timestamped section header. On non-zero exit, point the
# user at the log via _message and return 1 — the caller will propagate
# the failure and run_installers will surface it in the summary.
# Usage: apt_run "label for the log header" command args...
apt_run() {
    _ar_label="$1"
    shift
    {
        echo
        echo "==== $(date '+%Y-%m-%d %H:%M:%S') ${_ar_label} ===="
        echo "$ $*"
    } >> "$APT_LOG"
    if ! "$@" >> "$APT_LOG" 2>&1; then
        _message "⛔️ ${_ar_label} failed — see ${APT_LOG} for output"
        return 1
    fi
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

# direnv: https://github.com/direnv/direnv/releases
# Installed on Coder from upstream so the bundled stdlib is current; the
# apt-packaged direnv ships a stale stdlib (e.g. missing dotenv_if_exists).
DIRENV_VERSION="2.37.1"
DIRENV_SHA256_LINUX_AMD64="1f1b93dd6f38523fde26dfac96151ef9d31a374e3005cd3345fb93555ae0c9b5"
DIRENV_SHA256_LINUX_ARM64="2a9cef8d73521d6a3ec3f2871c4b747b8c4cc038628c1b57a7efa42b393a2d82"
DIRENV_SHA256_DARWIN_AMD64="24fb9ce48b563d7e9fbdd3a4e3e836941654a31ce3e67eba9eaafc3dcd8ae73b"
DIRENV_SHA256_DARWIN_ARM64="4f569f3a36732bfd8b8fea7bfcc6ad87a59745c109022164d0ca4832451d5369"
# END included from installers/versions.sh
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

                # Stitch git on top of the existing working tree without disturbing
                # it. The previous implementation used `git checkout -ft origin/main`
                # which silently discarded any local edits to tarball-extracted
                # files. Instead, point HEAD/index at origin/${GIT_BRANCH} via
                # plumbing commands and leave the working tree alone — git status
                # will then surface any drift between the working tree and remote.
                git update-ref "refs/heads/${GIT_BRANCH}" "$(git rev-parse "origin/${GIT_BRANCH}")"
                git symbolic-ref HEAD "refs/heads/${GIT_BRANCH}"
                git read-tree HEAD
                git branch --set-upstream-to="origin/${GIT_BRANCH}" "${GIT_BRANCH}" --quiet 2>/dev/null || true

                if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
                    _message "⚠️  working tree differs from origin/${GIT_BRANCH} — local edits preserved"
                fi

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

    # shellcheck source=installers/installer.sh # no-include

    . "${DOTFILES}/installers/installer.sh"

}

update "$@"
