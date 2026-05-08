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

# Read a declarative dotfiles env file. The format is intentionally tiny so
# fish and POSIX shells can both parse it. Directives (one per line, space-
# separated) are:
#
#   env VAR=VALUE       export an environment variable
#   path DIR            append DIR to PATH (skipped if DIR isn't a directory)
#   path-prepend DIR    move/prepend DIR to front of PATH (skipped if not a dir)
#
# Blank lines and lines starting with '#' are ignored. Values may reference
# $HOME and $DOTFILES (and any other already-exported variable).
_dotfiles_load_env () {
    _df_file="$1"
    [ -r "$_df_file" ] || return 0

    while IFS= read -r _df_line || [ -n "$_df_line" ]; do
        case "$_df_line" in
            ''|\#*) continue ;;
        esac

        _df_dir=${_df_line%% *}
        _df_arg=${_df_line#* }

        case "$_df_arg" in
            *\$*) _df_arg=$(eval printf '%s' "\"$_df_arg\"") ;;
        esac

        case "$_df_dir" in
            path)         pathadd "$_df_arg" ;;
            path-prepend) pathpromote "$_df_arg" ;;
            env)
                _df_key=${_df_arg%%=*}
                _df_val=${_df_arg#*=}
                export "$_df_key=$_df_val"
                ;;
            *)
                printf 'dotfiles: unknown directive %s in %s\n' \
                    "$_df_dir" "$_df_file" >&2
                ;;
        esac
    done < "$_df_file"

    unset _df_file _df_line _df_dir _df_arg _df_key _df_val
}
