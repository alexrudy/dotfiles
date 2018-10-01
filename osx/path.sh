if [ -d "/Applications/Server.app/Contents/ServerRoot/usr/" ]; then
    pathdemote /Applications/Server.app/Contents/ServerRoot/usr/bin
    pathdemote /Applications/Server.app/Contents/ServerRoot/usr/sbin
fi
pathadd "$DOTFILES/osx/bin"

if [ -f "$DOTFILES/osx/defaultbrowser/defaultbrowser" ]; then
  ln -s "$DOTFILES/osx/defaultbrowser/defaultbrowser" "$DOTFILES/osx/bin/defaultbrowser"
fi