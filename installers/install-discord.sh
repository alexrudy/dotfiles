#!/usr/bin/env sh
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
    sudo apt-get --quiet update -y  > /dev/null

    # Python dev/build dependencies
    sudo apt-get --quiet install --no-install-recommends -y \
        $(< ${DOTFILES}/discord/apt-install.txt) > /dev/null

    sudo apt-get --quiet install --only-upgrade --no-install-recommends -y \
        $(< ${DOTFILES}/discord/apt-upgrade.txt) > /dev/null

    _finished "✅ finished apt packages"

}

CODER_USERNAME=${CODER_USERNAME:-}

if test ! -z "$CODER_USERNAME" ; then
    # Discord-specific installation steps

    _process "👾 Coder Specific Install Steps"

    github_cli

    apt_packages()

    (. ${DOTFILES}/python/bin/install-pyenv.sh)

    _process "🐍 pyenv for discord"
    DISCORD_PYTHON="${DISCORD_PYTHON:-3.7.5}"
    _debug "👾 Installing discord python ${DISCORD_PYTHON}"
    pyenv install -s "$DISCORD_PYTHON"
    pyenv global $(< "${DOTFILES}/python/python-versions.txt") "$DISCORD_PYTHON" system
    _finished "✅ finished pyenv"


    if ! command_exists pipx; then
        _process "🐍 pipx"
        $(pyenv which python3.11) -m pip install pipx
        _finished "✅ finished pipx"
    fi

    _finished "✅ Coder Specific Install Steps"
fi
