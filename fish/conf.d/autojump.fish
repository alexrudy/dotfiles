if status is-interactive
    set PREFIX "/usr/local" "$HOMEBREW_PREFIX" "/opt/homebrew"
    for p in $PREFIX
        if test -f "$p/share/autojump/autojump.fish"
            source "$p/share/autojump/autojump.fish"
            break
        end
    end
end
