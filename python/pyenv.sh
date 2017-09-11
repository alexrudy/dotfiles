type pyenv &> /dev/null
if [ $? -eq 0 ]; then
	if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
	eval "$(pyenv init -)"
fi

