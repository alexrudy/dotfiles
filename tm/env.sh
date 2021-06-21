# 
#  env.bash
#  .dotfiles
#  
#  Created by Alexander Rudy on 2012-10-07.
#  Copyright 2012 Alexander Rudy. All rights reserved.
# 
if command_exists mate; then
    tm() {
        if [[ $# -gt 0 ]] && [[ -a $1 ]]; then
            mate -w $@
        else
            mate $@
        fi
    }
	export EDITOR='mate -w'
	export GIT_EDITOR="mate --name 'Git Commit Message' -w -l 1"
fi
