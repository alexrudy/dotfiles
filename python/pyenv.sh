type pyenv &> /dev/null
if [ $? -eq 0 ]; then
	eval "$(pyenv init -)"
	if which pyenv-virtualenvwrapper > /dev/null; then
    eval "$(pyenv virtualenvwrapper init -)"
  fi
fi

