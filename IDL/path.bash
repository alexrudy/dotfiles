# 
#  path.bash
#  .dotfiles
#  
#  Created by Alexander Rudy on 2012-10-07.
#  Copyright 2012 Alexander Rudy. All rights reserved.
# 
IDL="/Applications/itt/idl/idl/bin/"
if [ -d $IDL ]; then
	export PATH="$PATH:$IDL"                            #IDL
	export IDL_PATH=$HOME/Development/Astronomy/IDL/astron/
fi
IDL="/Applications/itt/idl/idl81/bin/"
if [ -d $IDL ]; then
	export PATH="$PATH:$IDL"
fi
