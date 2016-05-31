if [ -f "$MPPREFIX/bin/port" ]; then
    pathprepend "$MPPREFIX/bin"
    pathprepend "$MPPREFIX/sbin"                            #Macports Path Prefix
    pathadd "$MPPREFIX/libexec/perl5.12/sitebin"
fi

tmp () {
    tmux_new_or_respawn MacPorts
}