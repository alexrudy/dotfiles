if [ -d "$MPPREFIX" ]; then
    export VIRTUALENVWRAPPER_PYTHON="$MPPREFIX/bin/python"
else
    if [ -f '/usr/local/bin/python' ]; then
        export VIRTUALENVWRAPPER_PYTHON='/usr/local/bin/python'
    fi
fi
export VIRTUAL_ENV_DISABLE_PROMPT=1