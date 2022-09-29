# shellcheck shell=bash
# This is the core script for loading all of the dotfiles in this directory.

configure() {
	if [ -z "$2" ] || [ "$(basename "$1")" != "completion.$2" ]; then
		if [ "$(dirname "$1")" != "${DOTFILES}/installers" ]; then
			if [ -e "$1" ] && ! [ -x "$1" ]; then
				# shellcheck disable=SC1090
				source "$1"
			fi
		fi
	fi
}

# use .localrc for SUPER SECRET CRAP that you don't
# want in your public, versioned repo.
if [ -r "${HOME}/.localrc" ];
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
	configure "$filename" "sh"
done

# Shell files specific to a shell
if [ -n "$BASH" ]; then
	for filename in "$DOTFILES"/*/*.bash
	do
		configure "$filename" "bash"
	done
fi

if [ -n "$ZSH_NAME" ]; then
	for filename in "$DOTFILES"/*/*.zsh
	do
		configure "$filename" "zsh"
	done
fi


# Load completion scripts
for filename in "$DOTFILES"/*/completion.sh
do
	source "$filename"
done

if [ -n "$BASH" ]; then
	for filename in "$DOTFILES"/*/completion.bash
	do
		source "$filename"
	done
fi

if [ -n "$ZSH_NAME" ]; then
	for filename in "$DOTFILES"/*/completion.zsh
	do
		source "$filename"
	done

	# initialize autocomplete here, otherwise functions won't be loaded
    autoload -U compinit
    compinit
fi
