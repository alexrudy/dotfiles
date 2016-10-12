# This file activates python tools that should be running on startup.


# Virtualenv wrapper
# Installed via macports, so we only run it here.
if [ -f $MPPREFIX/bin/port ]; then
    if [ -f /opt/local/bin/virtualenvwrapper.sh ]; then
        export WORKON_HOME="$HOME/.virtualenvs/"
        if [ -d "$HOME/Development/" ]; then
            export PROJECT_HOME="$HOME/Development/"
        fi
        VIRTUALENVWRAPPER_PYTHON="$MPPREFIX/bin/python"
        # Python virtualenvwrapper loads really slowly, so load it on demand.
        if [[ $(whence -w workon) != "workon: function" ]]; then
            virtualenv_funcs=( workon deactivate mkvirtualenv )
            load_virtualenv() {
                # If these already exist, then virtualenvwrapper won't override them.
                unset -f "${virtualenv_funcs[@]}"
                # virtualenvwrapper doesn't load if PYTHONPATH is set, because the
                # virtualenv python doesn't have the right modules.
                _pp="$PYTHONPATH"
                unset PYTHONPATH
                # Attempt to load virtualenvwrapper from its many possible sources...
                _try_source() { [[ -f $1 ]] || return; source "$1"; return 0; }
                _try_source $MPPREFIX/bin/virtualenvwrapper.sh || \
                _try_source /usr/local/bin/virtualenvwrapper.sh || \
                _try_source /etc/bash_completion.d/virtualenvwrapper || \
                _try_source /usr/bin/virtualenvwrapper.sh 
                _status=$?
                unset -f _try_source
                # Restore PYTHONPATH
                [[ -n $_pp ]] && export PYTHONPATH="$_pp"
                # Did loading work?
                if [[ $_status != 0 || $(whence -w $1) != "$1: function" ]]; then
                    echo "Error loading virtualenvwrapper, sorry" >&2
                    return $_status
                fi
                # Chain-load the appropriate function
                "$@"
             }
            for v in "${virtualenv_funcs[@]}"; do
                eval "$v() { load_virtualenv $v \"\$@\"; }"
            done
        fi
        
        
    fi
fi
