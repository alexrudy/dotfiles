#!/usr/bin/env bash
# 
#  checkpy.sh
#  .dotfiles
#  
#  Created by Alexander Rudy on 2012-10-17.
#  Copyright 2012 Alexander Rudy. All rights reserved.
# 

files=$(find *)

for file in $files
do
	value=$(port provides $file | grep :)
	pport=${value##*:}
	if [ -z "$value" ]; then
		echo "${file##*/} is an orphan"
	else
		echo "${file##*/} belongs to $pport"
	fi
done
	