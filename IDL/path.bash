# 
#  path.bash
#  .dotfiles
#  
#  Created by Alexander Rudy on 2012-10-07.
#  Copyright 2012 Alexander Rudy. All rights reserved.
# 
IDL82="/Applications/exelis/idl/bin/"
IDL81="/Applications/itt/idl/idl/bin/"
if [ -d $IDL82 ]; then
	export PATH="$PATH:$IDL82"                           #IDL
	# export IDL_STARTUP="$HOME/.idl.pro"
	export IDL_STARTUP="IDLStartup.pro"
	
elif [ -d $IDL81 ]; then
	export PATH="$PATH:$IDL81"                           #IDL
	# export IDL_STARTUP="$HOME/.idl.pro"
	export IDL_STARTUP="IDLStartup.pro"
fi

function UCOIDL () {
	export LM_LICENSE_FILE=1700@localhost
	ssh -f -N -L1700:license:1700 -L35673:license:35673 ssh.ucolick.org
}

