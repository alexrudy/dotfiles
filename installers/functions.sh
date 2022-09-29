#!/usr/bin/env sh
# shellcheck disable=SC3043
set -eu

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
