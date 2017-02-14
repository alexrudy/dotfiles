if [ -d "/Applications/Server.app/Contents/ServerRoot/usr/" ]; then
    pathdemote /Applications/Server.app/Contents/ServerRoot/usr/bin
    pathdemote /Applications/Server.app/Contents/ServerRoot/usr/sbin
fi
pathadd "$DOTFILES/osx/bin"