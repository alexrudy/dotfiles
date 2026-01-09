if status is-interactive; and command -v starship > /dev/null
    starship init fish | source
    if test -e "/opt/coder/coder"
        test -z "$XDG_CONFIG_PATH"; and set --local XDG_CONFIG_PATH "$HOME/.config"
        set -gx STARSHIP_CONFIG "$XDG_CONFIG_PATH/starship.discord.toml"
    end
end
