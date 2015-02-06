# 
#  path.bash
#  .dotfiles
#  
#  Created by Alexander Rudy on 2013-02-07.
#  Copyright 2013 Alexander Rudy. All rights reserved.
# 

if [ -d "/usr/local/osiris/drs/scripts/" ]; then
    # Contents of /usr/local/osiris/drs/scripts/
    export OSIRIS_ROOT=/usr/local/osiris/drs
    
    export OSIRIS_WROOT=$OSIRIS_ROOT
    # Location of data files
    export OSIRIS_DRP_DATA_PATH=$OSIRIS_WROOT/data/

    # Set the queue directory for any pipelines started by this user
    export DRF_QUEUE_DIR=$OSIRIS_WROOT/drf_queue

    # Set a default for the overall (general) DRP log files to go.  These log
    # files are created each time the pipeline backbone is started
    export OSIRIS_DRP_DEFAULTLOGDIR=$OSIRIS_WROOT/drf_queue/logs

    # This is where the backbone IDL code looks for the shared libraries that
    # implement C code called by the IDL code.
    export OSIRIS_DRP_EXTERNAL_LIB_DIR=$OSIRIS_ROOT/modules/source

    # This is where the backbone IDL code looks for the shared libraries that
    # implement C code called by the IDL code.
    export OSIRIS_BACKBONE_DIR=$OSIRIS_ROOT/backbone

    # Specify where the configuration filename is stored. This file just
    # contains the real name of the configuration file.
    export OSIRIS_DRP_CONFIG_FILE=$OSIRIS_ROOT/backbone/SupportFiles/local_osirisDRPConfigFile
    
    export OSIRIS_IDL_BASE=$OSIRIS_ROOT
    
    export PATH=${PATH}:${OSIRIS_ROOT}/scripts
    export IDL_PATH=+${OSIRIS_ROOT}/../ql2:/usr/local/pkg/astron/pro:${IDL_PATH:-<IDL_DEFAULT>}
    
    export QL_FILEDIR=/usr/local/osiris/ql2
	
	# Fixes a bug with awt on OSX
	export JAVA_TOOL_OPTIONS='-Djava.awt.headless=false'
fi