# 
#  path.bash
#  .dotfiles
#  
#  Created by Alexander Rudy on 2012-10-07.
#  Copyright 2012 Alexander Rudy. All rights reserved.
# 
VMWare_PATH="/Library/Application Support/VMware Fusion"
if [ -d "$VMWare_PATH" ]; then
	export PATH="$PATH:$VMWare_PATH"              #VMWare Fusion Tools
fi
