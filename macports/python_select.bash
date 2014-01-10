#==================================
# Python Select Compensation
#==================================
#PYTHON Variables


function port_python_alias () {
    
    
    GETPYTHONREGEX="s/^.*py[A-Za-z]+([0-9])([0-9]+)-?[A-Za-z]*.*$/\1.\2/"
    COMMAND="port select --show python"
    
    PYVERSION=`$COMMAND  | sed -E $GETPYTHONREGEX `
    PORT_BIN="$MPPREFIX/bin"
    PORT_PY_BIN="$MPPREFIX/Library/Frameworks/Python.framework/Versions/2.7/bin"
    
    files=`find $PORT_BIN/*-$PYVERSION`
    
    for file in $files
    do
        dirname=${file%/*}
        rootname=${file##*/}
        program=${rootname%-*}
        if [ ! -e "$dirname/$program" ]; then
            sudo ln -s "$file" "$dirname/$program"
        fi
    done
    
    files=`find $PORT_PY_BIN/*-$PYVERSION`
    
    for file in $files
    do
        dirname=${file%/*}
        rootname=${file##*/}
        program=${rootname%-*}
        if [ ! -e "$dirname/$program" ]; then
            sudo ln -s "$file" "$dirname/$program"
        fi
    done
    
    
    PYVERSIONSHORT=`echo $PYVERSION | sed -E 's/\.//g'`
    
    PYDIR=py-$PYVERSIONSHORT
    
    LOCALPY="~/.python"
    if [ -d $LOCALPY ]; then
        if [ -z $PYTHONPATH ]; then
            export PYTHONPATH="$LOCALPY"
        else
            export PYTHONPATH="${PYTHONPATH}:$LOCALPY"
        fi
        export PYTHONPATH="${PYTHONPATH}:~/.python/lib/python/site-packages:~/.python/lib/python$PYVERSION/site-packages"
        export PYTHONPATH="${PYTHONPATH}:~/.python/lib/python:~/.python/lib/python$PYVERSION"
    fi
    
    # if [ -z $PYTHONPATH ]; then
    #     export PYTHONPATH="${PYTHONPATH}:$MPPREFIX/Library/Python/$PYVERSION/site-packages"
    # else
    #     export PYTHONPATH="$MPPREFIX/Library/Python/$PYVERSION/site-packages"
    # fi
    # export PYTHONPATH="${PYTHONPATH}:/Library/Python/$PYVERSION/site-packages" #Add back system Library packages
    export PATH="$PATH:$COMMAND_PATH:$HOME/Library/Python/$PYVERSION/bin/:$MPPREFIX/Library/Frameworks/Python.framework/Versions/$PYVERSION/bin/"
    STSCI="/usr/local/stsci/$PYDIR/lib/python"
    if [ -d $STSCI ]; then
        export PYTHONPATH="${PYTHONPATH}:$STSCI" # PUT STSCI at the end
        export PATH="$PATH:/usr/local/stsci/$PYDIR/bin"
    fi
    
}

if [ -f $MPPREFIX/bin/port ]; then
    port_python_alias
fi