if [ -f "/usr/local/bin/brew" ]; then
	eval "$(/usr/local/bin/brew shellenv)"
    pathprepend "/usr/local/bin"
	pathprepend "/usr/local/opt/llvm/bin"
	export LDFLAGS="-L/usr/local/opt/llvm/lib"
fi

if [ -f "/opt/homebrew/bin/brew" ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
fi
