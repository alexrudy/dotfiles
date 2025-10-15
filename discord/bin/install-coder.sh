#!/usr/bin/env bash
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

noninteractive() {
    echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
}

github_cli() {
    _process "🐙 github cli apt repo"

    noninteractive
    export DEBIAN_FRONTEND=noninteractive

    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd status=none of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    _finished "✅ finished github cli apt repo"
}

apt_packages() {
    _process "📦 apt packages"

    noninteractive
    export DEBIAN_FRONTEND=noninteractive

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
    if test -e "${HOME}/personalize" && test "$(realpath $(readlink "${HOME}/personalize"))" = "$(realpath ${DOTFILES}/discord/bin/coder-personalize.sh)"; then
        _debug "✅ already personalized"
    else
        _process "🧑🏼‍🎤 setting up ~/personalize"
        ln -s "$(realpath ${DOTFILES}/discord/bin/coder-personalize.sh)" "${HOME}/personalize"
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

install_buf() {
    if ! command_exists "buf"; then
        _process "🔨 buf"
        BUF_VERSION="1.57.0"
        curl -sSL \
        "https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-$(uname -s)-$(uname -m)" \
        -o "${HOME}/.bin/buf" && \
        chmod +x "${HOME}/.bin/buf"
        _finished "✅ finished buf"
    else
        _debug "✅ already installed buf"
        type buf
    fi
}

install_shpool() {
    if ! command_exists "shpool"; then
        _process "🔨 shpool"
        cargo install shpool
        curl -fLo "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/shpool.service" --create-dirs https://raw.githubusercontent.com/shell-pool/shpool/master/systemd/shpool.service
        sed -i "s|/usr|$HOME/.cargo|" "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/shpool.service"
        curl -fLo "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/shpool.socket" --create-dirs https://raw.githubusercontent.com/shell-pool/shpool/master/systemd/shpool.socket
        systemctl --user enable shpool
        systemctl --user start shpool
        _finished "✅ installed shpool"
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

    install_buf

    install_shpool

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
