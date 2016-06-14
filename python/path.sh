# This file activates python tools that should be running on startup.

if [[ -e "/usr/local/bin/virtualenvwrapper.sh" ]]; then
	VIRTUALENVWRAPPER="/usr/local/bin/virtualenvwrapper.sh"
else
	if [[ -e "$MPPREFIX/bin/virtualenvwrapper.sh" ]]; then
		VIRTUALENVWRAPPER="$MPPREFIX/bin/virtualenvwrapper.sh"
	fi
fi

# Virtualenv wrapper
# Installed via macports, so we only run it here.
if [ -f "$VIRTUALENVWRAPPER" ]; then
    export WORKON_HOME="$HOME/.virtualenvs/"
    if [ -d "$HOME/Development/" ]; then
        export PROJECT_HOME="$HOME/Development/"
    fi
	VIRTUALENVWRAPPER_PYTHON=$(which python)
    source $VIRTUALENVWRAPPER
fi
