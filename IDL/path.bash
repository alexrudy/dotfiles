# 
#  path.bash
#  .dotfiles
#  
#  Created by Alexander Rudy on 2012-10-07.
#  Copyright 2012 Alexander Rudy. All rights reserved.
# 
IDL="/Applications/itt/idl/idl/bin/"
if [ -d $IDL ]; then
	export PATH=$PATH:/Applications/itt/idl/idl/bin/                            #IDL
	export IDL_PATH=$HOME/Development/Astronomy/IDL/astron/
fi
