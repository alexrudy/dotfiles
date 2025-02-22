if command -v atuin > /dev/null; then
    eval "$(atuin init zsh)"
else
    zstyle ':prezto:load' pmodule 'history' 'history-substring-search'
fi
