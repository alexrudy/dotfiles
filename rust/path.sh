if [[ -d $HOME/.cargo ]]; then
  if [[ -f $HOME/.cargo/env ]]; then
    source $HOME/.cargo/env
  fi
fi

if command_exists rustc; then
  export DYLD_LIBRARY_PATH=$(rustc --print sysroot)/lib:$DYLD_LIBRARY_PATH
fi