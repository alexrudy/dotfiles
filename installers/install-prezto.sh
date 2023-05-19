#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

install_zprezto() {

    ZPREZTO="${ZDOTDIR:-$HOME}/.zprezto"

    if ! test -e "$ZPREZTO"; then
        _process "⛽️ Install zprezto"
        git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZPREZTO}"
        _finished "✅ Installed prezto"
    else
        _process "🚛 Update zprezto"
        _=$(git -C "${ZPREZTO}" pull --quiet --recurse-submodules)
        _finished "✅ Updated prezto"
    fi

    if ! test -e "${ZPREZTO}/contrib/fzf-tab"; then
        _process "📟 Install fzf-tab"
        git clone https://github.com/Aloxaf/fzf-tab "${ZPREZTO}/contrib/fzf-tab"
        _finished "✅ Installed fzf-tab"
    fi

}

install_zprezto
