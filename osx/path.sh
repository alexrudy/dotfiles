pathadd "$DOTFILES/osx/bin"


if command_exists xcode-select; then
    XCODE_PATH=$(xcode-select -p)
    if [ -d $XCODE_PATH ]; then
      pathadd $XCODE_PATH/usr/bin
    fi
fi