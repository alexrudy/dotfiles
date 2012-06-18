#==================================
# YORICK LANGUAGE
# PORTABLE MODE SETUP
#==================================
function yorick_port() {
	export PATH=$PATH:~/Development/Astronomy/Yorick/yorick #Yorick
    # alias yorick='rlwrap -s 2000 -c -f ~/.yorick/yorick.commands yorick'
	echo -e "Enabling ${RED}Yorick${BLUE} portable${NC} installation."
}

function yorick_home() {
    export PATH=$HOME/yorick-2.1.05/bin:$PATH #Yorick
    # alias yorick='rlwrap -s 2000 -c -f ~/.yorick/yorick.commands yorick'
	echo -e "Enabling ${RED}Yorick${BLUE} local${NC} installation."
}
