if command_exists brew; then
    [[ -f $HOMEBREW_PREFIX/etc/profile.d/autojump.sh ]] && . $HOMEBREW_PREFIX/etc/profile.d/autojump.sh
elif [[ -s $HOME/.autojump/etc/profile.d/autojump.sh ]]
    . $HOME/.autojump/etc/profile.d/autojump.sh
elif [[ -s /etc/profile.d/autojump.sh ]]
    . /etc/profile.d/autojump.sh
fi
