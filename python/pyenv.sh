if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    pathadd "$PYENV_ROOT/bin"
fi

type pyenv &> /dev/null
if [[ $? -eq 0 ]]; then
	eval "$(pyenv init -)"
	if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
fi
