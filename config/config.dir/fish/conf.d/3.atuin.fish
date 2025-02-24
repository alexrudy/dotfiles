

if status is-interactive
    if command -v atuin > /dev/null
        atuin init fish | source
    end

    if test -f "$HOME/.atuin/bin/env.fish"
        source "$HOME/.atuin/bin/env.fish"
    end
end
