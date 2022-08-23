if command_exists brew; then
    [[ -f $HOMEBREW_PREFIX/etc/profile.d/autojump.sh ]] && . $HOMEBREW_PREFIX/etc/profile.d/autojump.sh
fi
