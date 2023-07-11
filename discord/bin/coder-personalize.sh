#!/usr/bin/env sh
set -eu

if ! test -d ~/dotfiles; then
  git clone ssh://git@github.com/alexrudy/dotfiles.git
fi

if test -x ~/dotfiles/install.sh; then
  bash -l ~/dotfiles/install.sh || true
fi
