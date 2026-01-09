

if status is-interactive
    if command -v atuin > /dev/null
        atuin init fish | source
    end
end
