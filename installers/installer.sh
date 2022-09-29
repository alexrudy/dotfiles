#!/usr/bin/env sh
# shellcheck disable=SC3043
set -eu

GITHUB_REPO="${GITHUB_REPO:-alexrudy/dotfiles}"

DOTFILES="${DOTFILES:-${HOME}/.dotfiles/}"

# shellcheck source=installers/functions.sh
. "${DOTFILES}/installers/functions.sh"

download_dotfiles() {
    _process "📦  Acquiring Dotfiles"
   if test -d "${DOTFILES}" ; then
        if command_exists git; then
            if git -C "$DOTFILES" pull > /dev/null 2>&1 ; then
                _message "🐙 updated git repo"
            else
                _message "⚠️  failed to update git repo"
            fi
        fi
        _finished "✅ ${DOTFILES} exists. Skipping download."
   else
       if command_exists git; then
            _process "🐙 cloning ${GITHUB_REPO} from github"
            git clone "git@github.com/${GITHUB_REPO}.git" "${DOTFILES}"
            _finished "✅ ${DOTFILES} cloned"
       else
            _finished "⚠️  command git not found - falling back to tarball"
            _process "🌍 downloading archive of ${GITHUB_REPO} from github and extracting"
            curl -#fLo /tmp/dotfiles.tar.gz "https://github.com/${GITHUB_REPO}/tarball/main"
            mkdir -p "${DOTFILES}"
            tar -zxf /tmp/dotfiles.tar.gz --strip-components 1 -C "${DOTFILES}"
            rm -rf /tmp/dotfiles.tar.gz
            _finished "✅ ${DOTFILES} created, repository downloaded and extracted"
       fi;
   fi;
}

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
        # shellcheck disable=SC1090
        . "$filename" || true
    done
    _finished "✅ pre-requisites installed"
}


main() {
    echo "🚧  Installing dotfiles in ${DOTFILES}'"

    cd "${DOTFILES}"
    echo "$(date) [dotfiles] $0 $*" > "$LOGFILE"
    echo "$(date) [dotfiles] installing in ${DOTFILES}" >> "$LOGFILE"
    download_dotfiles
    run_installers
    link_dotfiles

    echo "🍾 Installation finshed - you might want to run '. \"\$HOME/.zshrc\"'"
}

main "$@"
