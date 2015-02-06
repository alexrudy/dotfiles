if [ -f "$MPPREFIX/bin/port" ]; then
    export PATH="$MPPREFIX/bin:$MPPREFIX/sbin:$PATH"                            #Macports Path Prefix
    export PATH="$PATH:$MPPREFIX/libexec/perl5.12/sitebin"
fi

tmp () {
    tmux-start MacPorts
}