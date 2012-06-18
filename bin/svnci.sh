#!/usr/bin/env bash
# Alexander Rudy
# July 7 2010

if [ $OSTYPE = darwin10.0 ]
then
	svn diff > svn-diff.diff
	mate svn-diff.diff
	svn ci
	rm svn-diff.diff
elif [ $OSTYPE = linux-gnu ]
then
	svn diff > svn-diff.diff
	emacs svn-diff.diff
	emacs svn-diff.diff &
	_SVNEDITOR=$SVN_EDITOR
	export SVN_EDITOR=emacs
	svn ci
	rm svn-diff.diff
	export SVN_EDITOR=$_SVNEDITOR
else
	echo "Not sure what system, I'm giving up"
	exit
fi

