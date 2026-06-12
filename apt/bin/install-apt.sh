#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

# Generic apt package install for any apt-based Linux. Pulls package
# names from apt/packages/apt-{install,upgrade}.txt. Coder/Discord
# specifics belong in discord/, not here — if a host should skip apt
# setup, set DOTFILES_SKIP_INSTALLERS=apt before running install/update.

if ! command_exists apt-get; then
    exit 0
fi

apt_packages() {
    _process "📦 apt packages (log: ${APT_LOG})"

    apt_run "apt-get update" sudo apt-get --quiet update -y

    if test -f "${DOTFILES}/apt/packages/apt-upgrade.txt"; then
        APT_UPGRADE=$(tr '\n' ' ' < "${DOTFILES}/apt/packages/apt-upgrade.txt")
        # shellcheck disable=SC2086
        apt_run "apt-get upgrade" sudo apt-get --quiet install --only-upgrade --no-install-recommends -y ${APT_UPGRADE}
    fi

    if test -f "${DOTFILES}/apt/packages/apt-install.txt"; then
        APT_INSTALL=$(tr '\n' ' ' < "${DOTFILES}/apt/packages/apt-install.txt")
        # shellcheck disable=SC2086
        apt_run "apt-get install" sudo apt-get --quiet install --no-install-recommends -y ${APT_INSTALL}
    fi

    _finished "✅ finished apt packages"
}

_process "🧑🏼‍💻 Linux apt setup"
apt_packages
_finished "✅ Linux apt setup"
