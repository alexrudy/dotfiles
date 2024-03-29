#!/usr/bin/env sh
# shellcheck disable=SC3043,SC2317
set -eu

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
