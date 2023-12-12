CODER_USERNAME=${CODER_USERNAME:-}
CODER=${CODER:-}

if test -n "$CODER_USERNAME" || test -n "$CODER" ; then
    # Discord Coder specific configuration
    export STARSHIP_CONFIG="${HOME}/.config/starship.discord.toml"

    if command_exists code; then
        export EDITOR='code -w'
        export GIT_EDITOR="code --wait"
    fi

    pathprepend "${DOTFILES}/discord/bin"

    alias discord='cd ~/dev/discord/discord'
else
    # Configuration for local machines
    ssh-coder() {
        CODER="${1:-bshm}"
        echo "connecting to coder.$CODER"
        ssh "coder.$CODER" -t 'tmux -CC new-session -A -s main'
    }

    alias ssc='ssh-coder'

    clyde-login() {
        clyde login gcloud -w "$1" > /dev/null 2>&1 &
        clyde login tsh -w "$1" > /dev/null 2>&1 &
        wait
    }

    alias cl='clyde-login'
fi
