if [ -f "/usr/local/bin/brew" ]; then
    pathprepend "/usr/local/bin"
	pathprepend "/usr/local/opt/llvm/bin"
	export LDFLAGS="-L/usr/local/opt/llvm/lib"
fi
