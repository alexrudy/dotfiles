if command_exists zed; then
    export EDITOR='zed --wait'
    export GIT_EDITOR="zed --wait"
elif command_exists code; then
    export EDITOR='code --wait'
    export GIT_EDITOR="code --wait"
fi
