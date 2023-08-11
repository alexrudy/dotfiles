command_exists () {
    type "$1" &> /dev/null ;
}

# Add fzf to path
if [ -d "${HOME}/.fzf/bin" ]; then
    pathadd "${HOME}/.fzf/bin"
fi

# Only run fzf if we can't find atuin.
if ! command_exists atuin; then
    [ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
    [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
