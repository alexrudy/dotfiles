# Uses git's autocompletion for inner commands. Assumes an install of git's
# bash `git-completion` script at $completion below (this is where Homebrew
# tosses it, at least).

completion=$MPPREFIX/share/git/contrib/completion/git-prompt.sh
if [ -f $completion ]; then
	source $completion
fi

if [ -n $BASH ] && [ -z $ZSH_NAME ]; then
    completion=$MPPREFIX/share/git/contrib/completion/git-completion.bash
    if [ -f $completion ]; then
    	source $completion
    fi
fi
if [ -n $ZSH_NAME ]; then
    completion=$MPPREFIX/share/git/contrib/completion/git-completion.zsh
    fpath=($MPPREFIX/share/git/contrib/completion/ $fpath)
fi



completion=~/.git-flow-completion
if [ -f $completion ]; then
	source $completion
fi
