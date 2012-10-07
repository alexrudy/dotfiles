# Custom Prompt Function
prompt=/opt/local/share/doc/git-core/contrib/completion/git-prompt.sh
export SYS_PS1=$PS1
if [ -f $prompt ]; then
	PS1='[\[\033[0;36m\]\u@\h \[\033[01;34m\]\W\[\033[00m\]$(__git_ps1 " (%s)")]\$ '
else
	PS1='[\[\033[0;36m\]\u@\h \[\033[01;34m\]\W\[\033[00m\]]\$ '
fi

# OLD PS1's
# export PS1="\[\033[0;36m\]\h:\[\033[01;34m\]\W\[\033[00m\] \u\$ "
# export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
	