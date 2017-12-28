if [[ -d $HOME/.cargo ]]; then
  if [[ -f $HOME/.cargo/env ]]; then
    source $HOME/.cargo/env
  fi
fi

export DYLD_LIBRARY_PATH=$(rustc --print sysroot)/lib:$DYLD_LIBRARY_PATH