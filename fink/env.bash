#==================================
# FINK Setup
#==================================

alias fink='finkinit'

function finkpython() {
    echo -e "${RED}Fink${NC} Python."
    /sw/bin/python2.6 $@
}

function finkinit() {
    unalias fink
    . /sw/bin/init.sh #Let FINK mess with the path etc.
    # alias fpy='/sw/bin/python2.6'
    # alias python=/usr/bin/python
    alias python='finkpython'
    #FINK Variables
    export CFLAGS=-I/sw/include 
    export LDFLAGS=-L/sw/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/sw/lib:/usr/local/lib
    export CXXFLAGS=$CFLAGS 
    export CPPFLAGS=$CXXFLAGS 
    export ACLOCAL_FLAGS="-I /sw/share/aclocal"
    export PKG_CONFIG_PATH="/sw/lib/pkgconfig"
    export PATH=/sw/var/lib/fink/path-prefix-10.6:$PATH
    export MACOSX_DEPLOYMENT_TARGET=10.6
    export PYTHONPATH=$PYTHONPATH:/sw/lib/python2.6/site-packages
    echo -e "Set ${RED}fink${NC} variables."
    export DONE_FINK=true
}

function finkswitch() {
    if [ -d /sw64 ]
    then
        if [ -d /sw ]
        then
            sudo mv /sw /sw32
            echo -e "Disabled ${GREEN}32-Bit ${RED}fink${NC}."
        fi
        if [ -d /sw64 ]
        then
            sudo mv /sw64 /sw
            finkinit
        else
            echo -e "No ${GREEN}64-Bit ${RED}fink${NC} is available."
        fi
        echo -e "Enabled ${GREEN}64-Bit ${RED}fink${NC}."
    elif [ -d /sw32 ]
    then
        if [ -d /sw ]
        then
            sudo mv /sw /sw64
            echo -e "Disabled ${GREEN}64-Bit ${RED}fink${NC}."
        fi
        if [ -d /sw32 ]
        then
            sudo mv /sw32 /sw
            finkinit
        else
            echo -e "No ${GREEN}32-Bit ${RED}fink${NC} is available."
        fi
        echo -e "Enabled ${GREEN}32-Bit ${RED}fink${NC}."
    else
        sudo mv /sw /sw64
        echo -e "Disabled ${GREEN}64-Bit ${RED}fink${NC}."
    fi
}

#==================================
# GIT support
#==================================

if [[ $FINK_GIT ]]
then
    alias git='gitsupport'

    function gitsupport() {
    	unalias git
    	if [ $DONE_FINK ]
        then
            echo -e "The ${RED}fink${NC} variables are already loaded."
        else
            finkinit
    	fi
    	echo -e "Try that ${RED}git${NC} command again!"
    }
# else
    # echo -e "No Fink GIT"
fi
