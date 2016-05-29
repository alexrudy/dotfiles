# Bash Completion
completion=$MPPREFIX/etc/bash_completion

if [ -f $completion ] && [ -z $ZSH_NAME ]; then
    source $completion
fi
