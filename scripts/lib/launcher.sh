#!/usr/bin/env bash

set -euo pipefail

dir=${SD_ROOT:-"$DOTFILES/scripts/library"}

error() {
    printf "\e[0;31mE:\e[0m%s" $1 >&2
}

while [[ $# > 0 ]]; do
  command="$1"
  shift
  if [[ -d "$dir/$command" ]]; then
    dir="$dir/$command"
  elif [[ -f "$dir/$command" ]]; then
    if [[ -x "$dir/$command" ]]; then
      "$dir/$command" "$@"
      exit 0
    else
      # For now, this is my very low-tech help system...
      cat "$dir/$command"
      exit 0
    fi
  else
    error "file not found!"
    error "$dir/$command"
    exit 1
  fi
done

if [[ -e "$dir.help" ]]; then
  cat "$dir.help"
  echo
else
  command=$(basename "$dir")
  echo "$command commands"
  echo
fi
no_commands=1
for file in $(find "$dir" -maxdepth 1 -mindepth 1 -exec test -x {} \; -print); do
  command=$(basename "$file")
  helpfile="$file.help"
  if [[ -f "$helpfile" ]]; then
    help=$(head -n1 "$helpfile")
  elif [[ -d "$file" ]]; then
    help="$command commands"
  else
    help=$(sed -nE -e '/^#!/d' -e '/^#/{s/^# *//; p; q;}' "$file")
  fi
  # this should really be a two-pass thing to calculate
  # the longest filename instead of hardcoding the spacing...
  # but oh well whatever
  if [[ -d "$file" ]]; then
    command="$command ..."
  fi
  printf '%-10s -- %s\n' "$command" "$help"
  no_commands=0
done

if [[ "$no_commands" -eq 1 ]]; then
  echo "(no subcommands found)"
fi