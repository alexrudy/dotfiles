#!/usr/bin/env bash
PYVERSION=`python -c 'import sys; print("{0.major:d}.{0.minor:d}".format(sys.version_info))'`

TARGET_SP="$VIRTUAL_ENV/lib/python$PYVERSION/site-packages"
SOURCE_PREFIX=$(cat $VIRTUAL_ENV/lib/python$PYVERSION/orig-prefix.txt)
SOURCE_SP="$SOURCE_PREFIX/lib/python$PYVERSION/site-packages"

if ! find $TARGET_SP -name "_tkinter.*"; then
    echo "Found _tkinter"
    echo $(find $TARGET_SP -name "_tkinter.*")
else
    SOURCE=$(find $SOURCE_SP -name "_tkinter.*")
    echo "Found source $SOURCE"
    ln -s $SOURCE $TARGET_SP/`basename $SOURCE`
fi