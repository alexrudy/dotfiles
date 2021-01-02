if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    pathadd "$PYENV_ROOT/bin"
fi