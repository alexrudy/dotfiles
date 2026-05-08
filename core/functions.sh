# Some basic functions required for configuration

pathadd () {
    case ":${PATH}:" in
        *":$1:"*) ;;
        *) [ -d "$1" ] && PATH="${PATH:+$PATH:}$1" ;;
    esac
}

pathprepend () {
    case ":${PATH}:" in
        *":$1:"*) ;;
        *) [ -d "$1" ] && PATH="$1${PATH:+:$PATH}" ;;
    esac
}

pathpromote () {
    pathdrop "$1"
    [ -d "$1" ] && PATH="$1${PATH:+:$PATH}"
}

pathdemote () {
    pathdrop "$1"
    [ -d "$1" ] && PATH="${PATH:+$PATH:}$1"
}

pathdrop () {
    PATH=$(printf '%s' "$PATH" | awk -v RS=: -v ORS=: -v drop="$1" '$0 != drop' | sed 's/:$//')
}

epath () {
    printf '%s\n' "$PATH" | tr ':' '\n'
}

command_exists () {
    type "$1" > /dev/null 2>&1
}

change_ext () {
	if [ -d "$1" ]; then
		for file in "$1"/*."$2"
		do
			target=${file%.*}
			git mv "$file" "$target.$3"
		done
	fi
}
