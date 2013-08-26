#!/usr/bin/env bash
OIFS="$IFS"
IFS=$'\n' 
for file in `find "$1" -iname "*conflicted copy*"`
do
    fixed=`echo "$file" | sed 's/ (.*conflicted copy.*)//'`
    echo "'$file' conflicts with $fixed'"
    echo "Use conflicted? [y/n]"
    read answer
    if [ "$answer" = "y" ]
    then
        echo "Fixing $file -> $fixed"
        mv "$file" "$fixed"
    else
        echo "Remove $file? [y/n]"
        read answer
        if [ "$answer" = "y" ]
        then
            echo "Removing $file.."
            rm "$file"
        fi
    fi
done
IFS="$OIFS"