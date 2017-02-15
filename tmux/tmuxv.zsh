tmuxv () {
    
    # Figure out where the project might be.
    venv=$1
    vproj=$(cat $WORKON_HOME/$1/.project)
    if [[ -f "$HOME/.tmuxp/$PROJECT.yaml" ]]; then
        vsession=$($DOTFILES/tmux/extract_session_name.py "$HOME/.tmuxp/$PROJECT.yaml")
    elif [[ -f "$vproj/.tmuxp.yml" ]]; then
        vsession=$($DOTFILES/tmux/extract_session_name.py "$vproj/.tmuxp.yml")
    else
        echo "Can't find a tmux session for environmnet $1"
        return
    fi
    tmuxp load -d $vproj && tmux -CC attach -t $vsession
}

tmuxl() {
    PROJECT=$1
    if [[ -f "$HOME/.tmuxp/$PROJECT.yaml" ]]; then
        SESSION_NAME=$($DOTFILES/tmux/extract_session_name.py "$HOME/.tmuxp/$PROJECT.yaml")
        tmuxp load -d $PROJECT && tmux -CC attach -t $SESSION_NAME
    else
        workon $PROJECT
        SESSION_NAME=$($DOTFILES/tmux/extract_session_name.py "./tmuxp.yaml")
        tmuxp load -d . && tmux -CC attach -t $PROJECT
    fi
}