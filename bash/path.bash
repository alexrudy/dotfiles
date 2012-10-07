# 
#  path.bash
#  .dotfiles
#  
#  Created by Alexander Rudy on 2012-10-07.
#  Copyright 2012 Alexander Rudy. All rights reserved.
# 

if [ -d $HOME/.bin ]; then
	export PATH=$PATH:$HOME/.bin
fi

if [ -d $BASH/bin ]; then
	export PATH=$PATH:$BASH/bin
fi