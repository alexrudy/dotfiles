# shellcheck shell=bash
set -euo pipefail

# This is the core script for loading all of the dotfiles in this directory.

configure() {
	if test -z "$2" || test "$(basename "$1")" != "completion.$2"; then
		if test -a "$1" && ! test -x "$1"; then
			# shellcheck disable=SC1090
			source "$1"
		fi
	fi
}

# use .localrc for SUPER SECRET CRAP that you don't
# want in your public, versioned repo.
if test -a "${HOME}/.localrc"
then
  configure "${HOME}/.localrc"
fi

# First, grab the path manipulation functions, etc.
for filename in "$DOTFILES"/core/*.sh
do
	configure "$filename" "sh"
done

# Now grab base shell files.
for filename in "$DOTFILES"/*/*.sh
do
	if [[ $(dirname "$filename") != "$DOTFILES/installers" ]]; then
		configure "$filename" "sh"
	fi;
done

if [[ -n "$BASH" ]]; then
	for filename in "$DOTFILES"/*/*.bash
	do
		configure "$filename" "bash"
	done
fi

if [[ -n "$ZSH_NAME" ]]; then
	for filename in "$DOTFILES"/*/*.zsh
	do
		configure "$filename" "zsh"
	done

	# initialize autocomplete here, otherwise functions won't be loaded
    # autoload -U compinit
    # compinit

fi

# load every completion after autocomplete loads
for filename in "$DOTFILES"/*/completion.sh
do
	configure "$filename"
done

if [[ -n "$BASH" ]]; then
	for filename in "$DOTFILES"/*/completion.bash
	do
		configure "$filename"
	done
fi

if [[ -n "$ZSH_NAME" ]]; then
	for filename in "$DOTFILES"/*/completion.zsh
	do
		configure "$filename"
	done

	autoload -U compinit && compinit
fi
