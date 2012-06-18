#==================================
# Python Select Compensation
#==================================
#PYTHON Variables


function port_python_alias () {
	GETPYTHONREGEX="s/^.*py[A-Za-z]+([0-9])([0-9]+)-?[A-Za-z]*.*$/\1.\2/"
	COMMAND="port select --show python"
	PYVERSION=`$COMMAND  | sed -E $GETPYTHONREGEX `
	
	PORT_BIN='/opt/local/bin'
	
	files=`find $PORT_BIN/*-$PYVERSION`
	
	for file in $files
	do
		rootname=${file##*/}
		program=${rootname%%-*}
		alias $program=$file
	done
	
	alias python3=python3.2
	
	PYVERSIONSHORT=`echo $PYVERSION | sed -E 's/\.//g'`
	
	PYDIR=py-$PYVERSIONSHORT
	
	export PYTHONPATH=~/.python
	export PYTHONPATH=${PYTHONPATH}:/Library/Python/$PYVERSION/site-packages
	export PYTHONPATH=${PYTHONPATH}:~/.python/lib/python/site-packages:~/.python/lib/python$PYVERSION/site-packages
	export PYTHONPATH=${PYTHONPATH}:~/.python/lib/python:~/.python/lib/python$PYVERSION

	export PYTHONPATH=${PYTHONPATH}:/usr/local/stsci/$PYDIR/lib/python
	export PATH=$PATH:/usr/local/stsci/$PYDIR/bin
	export PATH=$PATH:/opt/local/Library/Frameworks/Python.framework/Versions/$PYVERSION/bin/
}

port_python_alias