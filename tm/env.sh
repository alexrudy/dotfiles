# 
#  env.bash
#  .dotfiles
#  
#  Created by Alexander Rudy on 2012-10-07.
#  Copyright 2012 Alexander Rudy. All rights reserved.
# 
if command_exists mate; then
    tm() {
        mate -w $@
    }
	export EDITOR='tm'
	export GIT_EDITOR="mate --name 'Git Commit Message' -w -l 1"
fi
