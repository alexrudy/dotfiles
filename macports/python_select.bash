#==================================
# Python Select Compensation
#==================================
#PYTHON Variables

function port_python_version () {
  if [ -z $PYVERSION ]; then
    local GETPYTHONREGEX="s/^.*py[A-Za-z]+([0-9])([0-9]+)-?[A-Za-z]*.*$/\1.\2/"
    local COMMAND="select"
    eval "PYVERSION=$(port $COMMAND --show python | sed -E $GETPYTHONREGEX)"
    PYVERSIONSHORT=`echo $PYVERSION | sed -E 's/\.//g'`
  fi
  echo "$PYVERSION"
}

function link_port_python () {
  files=(`find $1/*-$(port_python_version)`)
  for file in $files
  do
      dirname=${file%/*}
      rootname=${file##*/}
      program=${rootname%-*}
      if [ ! -e "$dirname/$program" ]; then
          echo "Linking $file to $program"
          sudo ln -s "$file" "$dirname/$program"
      fi
  done
}

function port_python_alias () {
    
    PYVERSION=$(port_python_version)
    PORT_BIN="$MPPREFIX/bin"
    PORT_PY_BIN="$MPPREFIX/Library/Frameworks/Python.framework/Versions/$PYVERSION/bin"
    
    link_port_python $PORT_BIN
    link_port_python $PORT_PY_BIN
    
    PYDIR="py-$PYVERSIONSHORT"
    
    # Add some local directories to the python path.
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
    # Add python bin/ directories to the shell path.
    pathprepend "$HOME/Library/Python/$PYVERSION/bin/"
    pathprepend "$MPPREFIX/Library/Frameworks/Python.framework/Versions/$PYVERSION/bin/"
    STSCI="/usr/local/stsci/$PYDIR/lib/python"
    if [ -d $STSCI ]; then
        export PYTHONPATH="${PYTHONPATH}:$STSCI" # PUT STSCI at the end
        pathadd "/usr/local/stsci/$PYDIR/bin"
    fi
    
    py3exe=`find $MPPREFIX/bin -name "python3.[0-9]" | sort | tail -n 1`
    if [[ -f $py3exe ]]; then
      if [ ! -e "$MPPREFIX/bin/python3" ]; then
        echo "Linking $py3exe to python3"
        sudo ln -s "$py3exe" "$MPPREFIX/bin/python3"
      fi
    fi
}

if [ -f $MPPREFIX/bin/port ]; then
	port_use_python=`port select --show python 2>&1 | grep "Error"`
	
	if [[ -z "$port_use_python" ]]; then
	    	port_python_alias
	fi
fi