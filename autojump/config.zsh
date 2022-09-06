if command_exists brew; then
    [[ -f $HOMEBREW_PREFIX/etc/profile.d/autojump.sh ]] && . $HOMEBREW_PREFIX/etc/profile.d/autojump.sh
fi

[[ -s $HOME/.autojump/etc/profile.d/autojump.sh ]] && . $HOME/.autojump/etc/profile.d/autojump.sh