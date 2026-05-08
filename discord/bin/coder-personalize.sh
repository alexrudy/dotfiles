#!/usr/bin/env sh
set -eu

# Pin the dotfiles ref used for first-run bootstrap. Defaults to `main` for
# back-compat, but a known-good sha or a long-lived `coder-stable` branch
# is safer — a bad commit on main can otherwise brick every fresh Coder
# box that personalizes afterwards.
DOTFILES_REF="${DOTFILES_REF:-main}"

# Skip the generic apt installer on Coder — Coder workspace images already
# have most packages, and any Coder-specific extras live in
# discord/apt-install.txt and are installed by install-coder-apt.sh.
DOTFILES_SKIP_INSTALLERS="${DOTFILES_SKIP_INSTALLERS:+${DOTFILES_SKIP_INSTALLERS},}apt"
export DOTFILES_SKIP_INSTALLERS

if test -d "${HOME}/.dotfiles"; then
    sh "${HOME}/.dotfiles/update.sh"
else
    sh -c "$(curl -fsSL "https://raw.githubusercontent.com/alexrudy/dotfiles/${DOTFILES_REF}/install.sh")"
fi

chsh -s /usr/bin/fish
