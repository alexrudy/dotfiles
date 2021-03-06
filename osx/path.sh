pathadd "$DOTFILES/osx/bin"

if [ -f "$DOTFILES/osx/defaultbrowser/defaultbrowser" ]; then
  mv "$DOTFILES/osx/defaultbrowser/defaultbrowser" "$DOTFILES/osx/bin/defaultbrowser"
fi

if command_exists xcode-select; then
    XCODE_PATH=$(xcode-select -p)
    if [ -d $XCODE_PATH ]; then
      pathadd $XCODE_PATH/usr/bin
    fi
fi