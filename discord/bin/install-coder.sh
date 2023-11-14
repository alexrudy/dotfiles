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
    sudo add-apt-repository -y ppa:git-core/ppa > /dev/null
    sudo add-apt-repository -y ppa:deadsnakes/ppa > /dev/null

    sudo apt-get --quiet update -y  > /dev/null

    APT_UPGRADE=$(tr '\n' ' ' < "${DOTFILES}/discord/apt-upgrade.txt")
    # shellcheck disable=SC2086
    sudo apt --quiet install --only-upgrade --no-install-recommends -y \
        ${APT_UPGRADE}


    APT_INSTALL=$(tr '\n' ' ' < "${DOTFILES}/discord/apt-install.txt")
    # Python dev/build dependencies
    # shellcheck disable=SC2086
    sudo apt --quiet install --no-install-recommends -y \
        ${APT_INSTALL}


    _finished "✅ finished apt packages"
}


personalize() {
    if test "$(readlink "${HOME}/personalize")" = "${DOTFILES}/discord/bin/coder-personalize.sh"; then
        _debug "✅ already personalized"
    else
        _process "🧑🏼‍🎤 setting up ~/personalize"
        ln -s "${DOTFILES}/discord/bin/coder-personalize.sh" "${HOME}/personalize"
        chmod +x "${HOME}/personalize"
        _finished "✅ finished setting up ~/personalize"
    fi
}

install_buildifier() {
    BUILDIFIER_VERSION="v6.3.3"
    BUILDIFIER_URL="https://github.com/bazelbuild/buildtools/releases/download/${BUILDIFIER_VERSION}/buildifier-linux-amd64"

    if ! command_exists buildifier; then
        _process "🔨 buildifier"
        curl -fsSL "${BUILDIFIER_URL}" -o "${HOME}/bin/buildifier"
        chmod +x "${HOME}/.bin/buildifier"
        _finished "✅ finished buildifier"
    else
        _debug "✅ already installed buildifier"
        type buildifier
    fi

}

CODER_USERNAME=${CODER_USERNAME:-}
CODER=${CODER:-}

if test ! -z "$CODER_USERNAME" || test ! -z "$CODER" ; then
    # Discord-specific installation steps

    _process "👾 Coder Specific Install Steps"

    personalize

    github_cli

    apt_packages

    install_buildifier

    # shellcheck source=python/bin/install-pyenv.sh
    . "${DOTFILES}/python/bin/install-pyenv.sh"

    _process "🐍 pyenv for discord"
    DISCORD_PYTHON="${DISCORD_PYTHON:-3.7.5}"

    # shellcheck disable=SC2031
    PYTHON_VERSIONS=$(tr '\n' ' ' < "${DOTFILES}/python/python-versions.txt")

    _debug "👾 Installing discord python ${DISCORD_PYTHON}"
    pyenv install -s "$DISCORD_PYTHON"
    # shellcheck disable=SC2086
    pyenv global ${PYTHON_VERSIONS} "$DISCORD_PYTHON" system
    _finished "✅ finished pyenv"


    if ! command_exists pipx; then
        _process "🐍 pipx"
        $(pyenv which python3.11) -m pip install pipx
        _finished "✅ finished pipx"
    fi

    _finished "✅ Coder Specific Install Steps"
fi
