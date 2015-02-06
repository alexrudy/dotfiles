# 
#  path.bash
#  .dotfiles
#  
#  Created by Alexander Rudy on 2012-10-07.
#  Copyright 2012 Alexander Rudy. All rights reserved.
# 
DS9SI="/usr/local/si"
if [ -d $DS9SI ]; then
	export PATH="$PATH:$DS9SI"
fi
