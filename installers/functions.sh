#!/usr/bin/env sh
# shellcheck disable=SC3043
set -eu

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
