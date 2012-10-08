if [ -f /opt/local/bin/port ]; then
	export LD_LIBRARY_PATH="/opt/local/lib:/usr/local/lib:$LD_LIBRARY_PATH"
	export LIBRARY_PATH="/opt/local/lib:/usr/local/lib:$LIBRARY_PATH"
	export CPATH="/opt/local/include"
	export DYLD_FALLBACK_LIBRARY_PATH="$DYLD_FALLBACK_LIBRARY_PATH:/opt/local/lib"
fi
