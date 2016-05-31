#==================================
#SCISOFT Setup
#==================================
function scisoft() {
	if [ -f "/Applications/scisoft/all/bin/Setup.bash" ]; then
		export PATH=${PRE_SCISOFT_PATH:-$PATH}
		export PRE_SCISOFT_PATH=${PATH}
		. /Applications/scisoft/all/bin/Setup.bash
		alias python=/usr/bin/python
		alias scipy=/Applications/scisoft/i386/bin/python
		echo -e "${LIGHTBLUE}Welcome to ${RED}SciSoft${CYAN} ${SCISOFT_VERSION}${LIGHTBLUE}!${NC}"
		export DONE_SCISOFT=true
	else
		echo -e "${RED}SciSoft${NC} can't be used here. The Scisoft binaries are not found!"
	fi
}
