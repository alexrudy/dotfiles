# 
#  path.bash
#  .dotfiles
#  
#  Created by Alexander Rudy on 2013-02-07.
#  Copyright 2013 Alexander Rudy. All rights reserved.
# 

if [ -d "/usr/local/osiris/drs/scripts/" ]; then
  source /usr/local/osiris/drs/scripts/setup_osirisDRPSetupEnv
  export PATH=${PATH}:${OSIRIS_ROOT}/scripts
  export IDL_PATH=${IDL_PATH}:+${OSIRIS_ROOT}/ql2
fi