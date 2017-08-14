type pyenv &> /dev/null
if [ $? -eq 0 ]; then
	eval "$(pyenv init -)"
fi