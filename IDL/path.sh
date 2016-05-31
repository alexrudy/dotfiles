# 
#  path.bash
#  .dotfiles
#  
#  Created by Alexander Rudy on 2012-10-07.
#  Copyright 2012 Alexander Rudy. All rights reserved.
# 
IDL83="/usr/local/exelis/idl/bin"
IDL82="/Applications/exelis/idl/bin"
IDL81="/Applications/itt/idl/idl/bin"
if [ -d $IDL83 ]; then
	pathadd "$IDL83"
	export LM_LICENSE_FILE="/usr/local/exelis/license/license.dat"
	export IDL_STARTUP="IDLStartup.pro"

elif [ -d $IDL82 ]; then
	pathadd "$IDL82"                           #IDL
	# export IDL_STARTUP="$HOME/.idl.pro"
	export IDL_STARTUP="IDLStartup.pro"
	
elif [ -d $IDL81 ]; then
	pathadd "$IDL81"                           #IDL
	# export IDL_STARTUP="$HOME/.idl.pro"
	export IDL_STARTUP="IDLStartup.pro"
fi

function UCOIDL () {
	export LM_LICENSE_FILE=1700@localhost
	ssh -f -N -L1700:license:1700 -L35673:license:35673 ssh.ucolick.org
}

