# Some basic fucntions required for configuraiton
pathadd () {
    if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="${PATH:+"$PATH:"}$1"
    fi
}

pathprepend () {
    if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1${PATH:+":$PATH"}"
    fi
}

pathdemote () {
    path=(${(@)path:#$1}, $1)
}

command_exists () {
    type "$1" &> /dev/null ;
}

change_ext () {
	if [[ -d "$1" ]]; then
		for file in $1/*.$2
		do
			target=${file%.*}
			git mv "$file" "$target.$3"
		done
	fi
}