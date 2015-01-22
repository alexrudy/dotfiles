#!/usr/bin/env bash
OIFS="$IFS"
IFS=$'\n'
remove=false
askremove=true
force=false

if [[ "$1" = "-h" ]]; then
    echo "Remove dropbox conflicted copy files..."
    exit 0
fi

if [[ "$1" = "-f" ]]; then
    shift
    echo "Forcing remove!"
    force=true
fi

for file in `find "$1" -iname "*conflicted copy*"`
do
    fixed=`echo "$file" | sed 's/ (.*conflicted copy.*)//'`
    echo "'$file' conflicts with $fixed'"
    if [[ "$force" = true ]]; then
        echo "Removing $file.."
        rm "$file"
    else
        echo "Use conflicted? [y/n]"
        read answer
        if [[ "$answer" = "y" ]]; then
            echo "Fixing $file -> $fixed"
            mv "$file" "$fixed"
        else
            if [[ "$askremove" = true ]]; then
                echo 'Remove unused conflict files? [y/n]'
                read answer
                if [[ "$answer" = "y" ]]; then
                    remove=true
                fi
                askremove=false
            fi
            if [[ "$remove" = true ]]; then
                echo "Removing $file.."
                rm "$file"
            fi
        fi
    fi
done
IFS="$OIFS"