if status is-interactive; and command -v direnv > /dev/null
    direnv hook fish | source
end
