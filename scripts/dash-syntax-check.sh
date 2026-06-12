#!/usr/bin/env sh
# POSIX-syntax check for installer scripts. `dash -n` parses each file
# without running it, catching bashisms (e.g. [[ ]]) that would break when
# the installers are sourced by install.sh under a real POSIX shell.
#
# Used as a pre-commit hook; pre-commit passes the matched files as args.
# dash -n only reads the first file argument, so loop one file at a time.
set -eu

status=0
for file in "$@"; do
    if ! dash -n "$file"; then
        echo "dash -n: POSIX syntax error in ${file}" >&2
        status=1
    fi
done
exit "$status"
