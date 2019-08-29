if [ -d "/Applications/Server.app/Contents/ServerRoot/usr/" ]; then
    pathdemote /Applications/Server.app/Contents/ServerRoot/usr/bin
    pathdemote /Applications/Server.app/Contents/ServerRoot/usr/sbin
fi
pathadd "$DOTFILES/osx/bin"

if [ -f "$DOTFILES/osx/defaultbrowser/defaultbrowser" ]; then
  mv "$DOTFILES/osx/defaultbrowser/defaultbrowser" "$DOTFILES/osx/bin/defaultbrowser"
fi

if which xcode-select > /dev/null; then
    XCODE_PATH=$(xcode-select -p)
    if [ -d $XCODE_PATH ]; then
      pathprepend $XCODE_PATH/usr/bin
    fi
fi