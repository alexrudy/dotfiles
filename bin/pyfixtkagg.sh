#!/usr/bin/env bash
PYVERSION=`python -c 'import sys; print("{0.major:d}.{0.minor:d}".format(sys.version_info))'`

TARGET_SP="$VIRTUAL_ENV/lib/python$PYVERSION/site-packages"
SOURCE_PREFIX=$(cat $VIRTUAL_ENV/lib/python$PYVERSION/orig-prefix.txt 2> /dev/null)
SOURCE_SP="$SOURCE_PREFIX/lib/python$PYVERSION/site-packages"

if ! find $TARGET_SP -name "_tkinter.*" 2> /dev/null; then
    echo "Found _tkinter"
    echo $(find $TARGET_SP -name "_tkinter.*" 2> /dev/null)
else
    SOURCE=$(find $SOURCE_SP -name "_tkinter.*" 2> /dev/null)
    echo "Found source:"
    echo "$SOURCE"
    ln -s $SOURCE $TARGET_SP/`basename $SOURCE`
    echo $(find $TARGET_SP -name "_tkinter.*" 2> /dev/null)
fi
