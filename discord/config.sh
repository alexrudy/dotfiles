CODER_USERNAME=${CODER_USERNAME:-}
CODER=${CODER:-}

if test -n "$CODER_USERNAME" || test -n "$CODER" ; then
    # Discord Coder specific configuration
    export STARSHIP_CONFIG="${HOME}/.config/starship.discord.toml"
fi



ssh-coder() {
    CODER="${1:-alex-builds-small-machines}"
    echo "connecting to coder.$CODER"
    ssh "coder.$CODER" -t 'tmux -CC new-session -A -s main'
}
