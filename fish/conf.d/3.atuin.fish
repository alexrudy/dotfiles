

if status is-interactive
    if test -f "$HOME/.atuin/bin/env.fish"
        source "$HOME/.atuin/bin/env.fish"
    end

    if command -v atuin > /dev/null
        atuin init fish | source
    end
end
