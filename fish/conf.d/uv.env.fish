if test -d "$HOME/.local/bin"
    fish_add_path "$HOME/.local/bin"

    if test -f "$HOME/.local/bin/env.fish"
        source "$HOME/.local/bin/env.fish"
    end
end
