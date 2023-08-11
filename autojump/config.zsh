if command_exists brew; then
    [[ -f $HOMEBREW_PREFIX/etc/profile.d/autojump.sh ]] && . $HOMEBREW_PREFIX/etc/profile.d/autojump.sh
elif [[ -s $HOME/.autojump/etc/profile.d/autojump.sh ]]; then
    . $HOME/.autojump/etc/profile.d/autojump.sh
elif [[ -s /etc/profile.d/autojump.sh ]]; then
    . /etc/profile.d/autojump.sh
elif [[ -s "/usr/share/autojump/autojump.sh" ]]; then
    . /usr/share/autojump/autojump.sh
fi
