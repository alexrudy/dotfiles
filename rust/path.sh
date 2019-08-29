if [[ -d $HOME/.cargo ]]; then
    pathprepend $HOME/.cargo/bin
fi

if command_exists rustc; then
  export DYLD_LIBRARY_PATH=$(rustc --print sysroot)/lib:$DYLD_LIBRARY_PATH
fi