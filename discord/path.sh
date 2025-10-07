if [ -d "$HOME/Development/discord/discord/.git" ]; then
    pathprepend "$HOME/Development/discord/discord/.local/bin"
    pathprepend "$DOTFILES/discord/bin"
fi

if [ -e "$HOME/Development/discord/discord/clyde" ]; then
    if [ ! -f "$DOTFILES/discord/bin/clyde" ]; then
        ln -s "$HOME/Development/discord/discord/clyde" "$DOTFILES/discord/bin/clyde"
    fi
fi

if [ -d "$HOME/dev/discord/discord/.git" ]; then
    pathprepend "$DOTFILES/discord/bin"
fi
