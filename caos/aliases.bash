#==================================
#Astronomy Software
#==================================

CAOS_DIR="$HOMEDevelopment/Astronomy/IDL/work_caos"
if [ -d $CAOS_DIR ]; then
	alias caos='cd $HOMEDevelopment/Astronomy/IDL/work_caos ; source caos_env.sh ; idl'
fi
