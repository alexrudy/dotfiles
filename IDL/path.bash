# 
#  path.bash
#  .dotfiles
#  
#  Created by Alexander Rudy on 2012-10-07.
#  Copyright 2012 Alexander Rudy. All rights reserved.
# 
IDL="/Applications/exelis/idl/bin"
if [ -d $IDL ]; then
	export PATH="$PATH:$IDL"                           #IDL
	export IDL_STARTUP="$HOME/.idl.pro"
fi

function UCOIDL () {
	export LM_LICENSE_FILE=1700@localhost
	ssh -f -N -L1700:license:1700 -L35673:license:35673 ssh.ucolick.org
}

