# 
#  aliases.bash
#  Useful XTERM defaults for IRAF
#  .dotfiles
#  
#  Created by Alexander Rudy on 2012-10-07.
#  Copyright 2012 Alexander Rudy. All rights reserved.
# 

alias xterm='xterm +ah -cr grey -sl 2048 -sb -bg black -fg white'
if command_exists xgterm; then
	alias xgterm='xgterm +ah -cr grey -sl 2048 -sb -bg black -fg white'
fi
