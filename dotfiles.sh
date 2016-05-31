# This is the core script for loading all of the dotfiles in this directory.

CONFIGURE_FILES=""
configure_from_file () {
	start=`/opt/local/bin/gdate +%s.%N`
	if [[ -n $2 ]] && [[ $(basename $1 ) != "completion.$2" ]]; then
		if [[ -a "$1" ]] && [[ ! -x "$1" ]] && [[ *":$1:"* != ":$CONFIGURE_FILES:" ]]; then
			source $1
			CONFIGURE_FILES="${CONFIGURE_FILES:+"$CONFIGURE_FILES:"}$1"
		fi
	fi
	end=`/opt/local/bin/gdate +%s.%N`
	duration=`echo "$end - $start" | bc`
	duration=`printf "%0.1f" $duration`
	if [[ "$duration" != "0.0" ]]; then
		echo "$duration: $1"
	fi
}

# use .localrc for SUPER SECRET CRAP that you don't
# want in your public, versioned repo.
if [[ -a ~/.localrc ]]
then
  source ~/.localrc
fi



# First, grab the path manipulation functions, etc.
for config_file in $DOTFILES/core/*.sh
do
	configure_from_file $config_file "sh"
done

# Now grab base shell files.
for config_file in $DOTFILES/*/*.sh
do
	configure_from_file $config_file "sh"
done

if [[ -n "$BASH" ]]; then
	for config_file in $DOTFILES/*/*.bash
	do 
		configure_from_file $config_file "bash"
	done
fi

if [[ -n "$ZSH_NAME" ]]; then
	for config_file in $DOTFILES/*/*.zsh
	do 
		configure_from_file $config_file "zsh"
	done
	
	# initialize autocomplete here, otherwise functions won't be loaded
	autoload -U compinit
	compinit
	
fi

# load every completion after autocomplete loads
for config_file in $DOTFILES/**/completion.sh
do 
	configure_from_file $config_file
done

if [[ -n "$BASH" ]]; then
	for config_file in $DOTFILES/**/completion.bash
	do 
		configure_from_file $config_file
	done
fi

if [[ -n "$ZSH_NAME" ]]; then
	for config_file in $DOTFILES/**/completion.zsh
	do 
		configure_from_file $config_file
	done
fi