# 
#  path.bash
#  .dotfiles
#  
#  Created by Alexander Rudy on 2012-10-07.
#  Copyright 2012 Alexander Rudy. All rights reserved.
# 

function pathadd () {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

export PATH
if [ -d $HOME/.bin ]; then
	pathadd "$HOME/.bin"
fi

if [ -d $BASH/bin ]; then
	pathadd "$BASH/.bin"
fi

