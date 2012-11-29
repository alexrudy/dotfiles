# 
#  path.bash
#  .dotfiles
#  
#  Created by Jaberwocky on 2012-11-29.
#  Copyright 2012 Jaberwocky. All rights reserved.
# 


UCOGIT="/local/git/bin"
if [ -d $UCOGIT ]; then
	export PATH=$PATH:$UCOGIT
fi