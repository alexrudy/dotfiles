CODER_USERNAME=${CODER_USERNAME:-}

if test ! -z "$CODER_USERNAME" ; then
    # Discord Coder specific configuration
    export STARSHIP_CONFIG="${HOME}/.config/starship.discord.toml"
fi