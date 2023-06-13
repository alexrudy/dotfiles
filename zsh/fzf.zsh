
# Only run fzf if we can't find atuin.
if !command_exists atuin; then
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    [ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
    [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
