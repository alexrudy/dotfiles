type pyenv &> /dev/null
if [[ $? -eq 0 ]]; then
	eval "$(pyenv init -)"
	if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
fi

