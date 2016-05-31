#
#  setup.bash
#  .dotfiles
#
#  Created by Alexander Rudy on 2014-12-31.
#  Copyright 2014 Alexander Rudy. All rights reserved.
#

ur_setup() {
    eval `$HOME/.ureka/ur_setup -sh $*`
}
ur_forget() {
    eval `$HOME/.ureka/ur_forget -sh $*`
}
