#!/usr/bin/env bash
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

github_cli() {
    _process "🐙 github cli apt repo"
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd status=none of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    _finished "✅ finished github cli apt repo"
}

apt_packages() {
    _process "📦 apt packages"

    _message "💾 apt update"
    # sudo apt-get --quiet update -y  > /dev/null
    # sudo apt-get install --no-install-recommends --quiet -y software-properties-common

    # _message "💾 add ppa repositories"
    # sudo add-apt-repository -y ppa:git-core/ppa > /dev/null
    # sudo add-apt-repository -y ppa:deadsnakes/ppa > /dev/null

    sudo apt-get --quiet update -y  > /dev/null

    if test -f "${DOTFILES}/apt/packages/apt-upgrade.txt"; then
        APT_UPGRADE=$(tr '\n' ' ' < "${DOTFILES}/apt/packages/apt-upgrade.txt")
        # shellcheck disable=SC2086
        sudo apt-get --quiet install --only-upgrade --no-install-recommends -y \
            ${APT_UPGRADE} &> /dev/null
    fi

    if test -f "${DOTFILES}/apt/packages/apt-install.txt"; then
        APT_INSTALL=$(tr '\n' ' ' < "${DOTFILES}/apt/packages/apt-install.txt")
        # shellcheck disable=SC2086
        sudo apt-get --quiet install --no-install-recommends -y \
            ${APT_INSTALL} &> /dev/null
    fi

    _finished "✅ finished apt packages"
}




CODER_USERNAME=${CODER_USERNAME:-}
CODER=${CODER:-}

if command_exists apt-get ; then
    # Discord-specific installation steps

    _process "🧑🏼‍💻 Linux Specific Install Steps"

    github_cli
    apt_packages

    _finished "✅ Linux Specific Install Steps"
fi
