#==================================
# YORICK LANGUAGE
# PORTABLE MODE SETUP
#==================================
function yorick_port() {
	YORICK="$HOME/Development/Astronomy/Yorick/yorick"
	if [ -d $YORICK ]; then
		export PATH=$PATH:$YORCIK #Yorick
	    # alias yorick='rlwrap -s 2000 -c -f ~/.yorick/yorick.commands yorick'
		echo -e "Enabling ${RED}Yorick${BLUE} portable${NC} installation."
	else
		echo -e "Can't find ${RED}Yorick${BLUE} portable${NC} installation!"
		exit 1
	fi
}

function yorick_home() {
	YORICK="$HOME/yorick-2.1.05/bin"
	if [ -d $YORICK ]; then
	    export PATH=$YORICK:$PATH #Yorick
	    # alias yorick='rlwrap -s 2000 -c -f ~/.yorick/yorick.commands yorick'
		echo -e "Enabling ${RED}Yorick${BLUE} local${NC} installation."
	else
		echo -e "Can't find ${RED}Yorick${BLUE} local${NC} installation!"
		exit 1
	fi
}
