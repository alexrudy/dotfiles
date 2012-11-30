#!/usr/bin/env bash
# 
#  install.sh
#  .dotfiles
#  
#  Created by Jaberwocky on 2012-11-30.
#  Copyright 2012 Jaberwocky. All rights reserved.
# 


files=`find */*.symlink`

for file in $files
do
	dest=${file%%.symlink}
	dest="."${dest##*/}
	if [ -e $HOME/$dest ]; then
		echo "File $dest already exists. Skipping"
	else
		echo "Linking $file to $dest"
		ln -s $file $HOME/$dest
	fi
done

directories=`find ./*/*.dir -type d -maxdepth 0`

for directory in $directories
do
	dest=${directory%%.dir}
	dest="."${dest##*/}
	if [ ! -d $directory ]; then
		echo "$directory is not a directory"
	elif [ -e $HOME/$dest ]; then
		echo "Directory $dest already exists. Skipping"
	else
		echo "Linking $directory to $dest"
		ln -s $directory $HOME/$dest
	fi
done