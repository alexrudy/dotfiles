# Custom Prompt Function
function prompt() {
    export SYS_PS1=$PS1
    export PS1="\[\033[0;36m\]\h:\[\033[01;34m\]\W\[\033[00m\] \u\$ "
	# export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
}
prompt
