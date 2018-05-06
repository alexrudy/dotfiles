fpath=($DOTFILES/domino/functions $fpath)
autoload -U $DOTFILES/domino/functions/*(:t)

if [[ -f "$HOME/go/src/github.com/evenco/even-server/scripts/dsync" ]]; then
	alias dsync="$HOME/go/src/github.com/evenco/even-server/scripts/dsync"
fi

if [[ -f "$HOME/go/src/github.com/evenco/even-server/scripts/domino.py" ]]; then
	alias dsync="$HOME/go/src/github.com/evenco/even-server/scripts/domino.py -c .dsync.yml"
fi
