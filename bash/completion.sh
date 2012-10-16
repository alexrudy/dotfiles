# Bash Completion
completion=$MPPREFIX/etc/bash_completion

if [ -f $completion ]; then
    source $completion
fi
