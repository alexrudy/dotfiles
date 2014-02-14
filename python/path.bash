# This file activates python tools that should be running on startup.


# Virtualenv wrapper
# Installed via macports, so we only run it here.
if [ -f $MPPREFIX/bin/port ]; then
    export WORKON_HOME="$HOME/.virtualenvs/"
    source /opt/local/bin/virtualenvwrapper.sh
fi