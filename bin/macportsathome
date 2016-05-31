#!/usr/bin/env bash
# 
#  macportsathome.sh
#  .dotfiles
#  
#  Created by Alex Rudy on 2012-10-08.
#  Copyright 2012 Alex Rudy. All rights reserved.
# 

if [ $# -ne 1 ]; then
	echo "Usage: $0 path/to/macports/soruces/"
	exit 1
fi

MPSOURCE=$1

set -x

cd $MPSOURCE
PATH=/usr/bin:/usr/sbin:/bin:/sbin ./configure \
--prefix=$HOME/.macports \
--enable-readline \
--with-install-user=`id -un` \
--with-install-group=`id -gn` \
--x-includes=/usr/X11R6/include \
--x-libraries=/usr/X11R6/lib \
--with-tclpackage=$HOME/.macports/share/macports/Tcl

make
make install