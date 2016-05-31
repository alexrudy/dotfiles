if [ -f "$MPPREFIX/bin/port" ]; then
    # export LD_LIBRARY_PATH="$MPPREFIX/lib:/usr/local/lib:$LD_LIBRARY_PATH"
    # export LIBRARY_PATH="$MPPREFIX/lib:/usr/local/lib:$LIBRARY_PATH"
	export CPATH="$MPPREFIX/include"
    # export DYLD_FALLBACK_LIBRARY_PATH="$DYLD_FALLBACK_LIBRARY_PATH:$MPPREFIX/lib"
fi
