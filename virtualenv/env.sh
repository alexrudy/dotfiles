if [ -f '/usr/local/bin/python3' ]; then
    export VIRTUALENVWRAPPER_PYTHON='/usr/local/bin/python3'
elif [ -f "/usr/local/bin/python" ]; then
	export VIRTUALENVWRAPPER_PYTHON='/usr/local/bin/python'
elif [ -f "$MPPREFIX/bin/python" ]; then
    export VIRTUALENVWRAPPER_PYTHON="$MPPREFIX/bin/python"
fi
export VIRTUAL_ENV_DISABLE_PROMPT=1