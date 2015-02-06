# This file activates python tools that should be running on startup.


# Virtualenv wrapper
# Installed via macports, so we only run it here.
if [ -f $MPPREFIX/bin/port ]; then
    export WORKON_HOME="$HOME/.virtualenvs/"
    if [ -d "$HOME/Development/" ]; then
        export PROJECT_HOME="$HOME/Development/"
    fi
    source /opt/local/bin/virtualenvwrapper.sh
fi

activatepy () {
    in_pwd=`pwd`
    workon "$@"
    cd "$in_pwd"
}