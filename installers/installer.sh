#!/usr/bin/env sh
# shellcheck disable=SC3043
set -eu

# shellcheck source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"

_target_filename() {
    name="$(basename "${1%.symlink}")"
    echo "${HOME}/.$name"
}

_target_dir() {
    name="$(basename "${1%.dir}")"
    echo "${HOME}/.$name"
}

link_dotfiles() {

    _process "🔗 linking .symlink files to home directory"
    find "${DOTFILES}" -maxdepth 2 -name '*.symlink' | while read -r filename; do
        link_dotfile "$filename"
    done
    _finished "✅ linked .symlink files"

    _process "🗂  linking .dir folders to home directory"
    find "${DOTFILES}" -maxdepth 2 -type d -name '*.dir' | while read -r directory; do
        link_dotdir "$directory"
    done
    _finished "✅ linked .dir directories"



}

link_dotdir() {

    dirname="$1"
    target=$(_target_dir "$dirname")
    shortname=$(basename "$target")

    if test -L "$target" && test -d "$(readlink -f "$target")" && test "$(readlink -f "$target")" = "$(readlink -f "$dirname")"; then
        true; # _message "✅ dotdir ${shortname} already linked"
    elif test -d "$target"; then
        merge_dotdir "$dirname" "$target" || _message "⛔️  failed to merge dotdir ${shortname} "
    elif test -e "$target"; then
        _message "⛔️ dotdir ${shortname} would conflict with existing directory entry"
    else
        ln -s "$(readlink -f "$dirname")" "$target"
        _message "✅ dotdir ${shortname} linked to ${dirname}"
    fi;

}

merge_dotdir() {
  local dirname target shortname canreplace
  dirname=$1
  target=$2
  shortname=$(basename "$target")
  canreplace=""
  _process "✨ merging $shortname"

  if command_exists rsync; then
    rsync -avP "${target}/" "${dirname}"
  else
    mkfifo dotdir_merge_pipe  > /dev/null 2>&1 || true
    find "$target" -maxdepth 1 > dotdir_merge_pipe &

    while read -r entryname; do
        _message "processing ${entryname}"
        targetentry=$entryname
        direntry="$dirname/$(basename "$entryname")"
        if test -e "$direntry" && test "$(readlink -f "$targetentry")" = "$(readlink -f "$direntry")"; then
            true # This entry already copied.
        elif test -e "$direntry"; then
            canreplace="false"
            _message "⚠️  entry ${entryname} would conflict with existing entry"
        else
            mv "$targetentry" "$dirname/"
            _message "✅  entry ${entryname} copied into dotfiles"
        fi;
    done  < dotdir_merge_pipe
  fi
  if test -z "$canreplace"; then
    rm -rf "$target"
    ln -s "$(readlink -f "$dirname")" "$target"
    _finished "✅ merged ${shortname}"
  else
    _finished "⛔️ unable to merge ${shortname} - some entries conflict with dotfiles"
  fi



}

link_dotfile() {
    filename="$1"
    target="$(_target_filename "$filename")"
    shortname="$(basename "$target")"

    if test -L "$target"; then
        if test "$(readlink -f "$target")" = "$(readlink -f "$filename")"; then
            true # _message "✅ dotfile ${shortname} already linked"
        else
            _message "⚠️  dotfile ${shortname} would conflict with file linked to $(readlink -f "$target")"
        fi
    elif test -e "$target" && ! test -d "$target"; then
        _message "⚠️  dotfile ${shortname} would conflict with existing file"
    elif test -e "$target"; then
        _message "⛔️ dotfile ${shortname} would conflict with existing directory entry"
    else
        ln -s "$(readlink -f "$filename")" "$target"
        _message "✅ dotfile ${shortname} linked to ${filename}"
    fi
}

run_installers() {
    local filename
    _process "💾 running stand-alone installers"

    find "${DOTFILES}" -maxdepth 3 -name 'install-*.sh' | while read -r filename; do
        _debug "🚀 running ${filename}"
        # shellcheck disable=SC1090
        (. "$filename") || true
    done
    _finished "✅ stand-alone items installed"
}


main() {
    _process "🚧 Installing dotfiles in ${1:-DOTFILES}"

    run_installers
    link_dotfiles

    _finished "🍾 Installation finshed - you might want to run '. \"\$HOME/.zshrc\"'"
}

main "$@"
