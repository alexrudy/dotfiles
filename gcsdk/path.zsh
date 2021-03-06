

source_inc() {
    if [ -f "$1" ]; then source "$1"; fi
}

if command_exists brew; then
    BREW_PREFIX=$(brew --prefix)
    source_inc "$BREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
else
    source_inc "$HOME/.google/google-cloud-sdk/path.zsh.inc"
fi