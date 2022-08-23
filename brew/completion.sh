if [ -f "$HOMEBREW_PREFIX/share/zsh-completions" ]; then
    fpath=($HOMEBREW_PREFIX/share/zsh-completions $fpath)
fi
