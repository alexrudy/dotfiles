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
    if test -e "${HOME}/personalize" && test "$(_realpath "${HOME}/personalize")" = "$(_realpath "${DOTFILES}/discord/bin/coder-personalize.sh")"; then
        _debug "✅ already personalized"
    else
        _process "🧑🏼‍🎤 setting up ~/personalize"
        ln -s "$(_realpath "${DOTFILES}/discord/bin/coder-personalize.sh")" "${HOME}/personalize"
        chmod +x "${HOME}/personalize"
        _finished "✅ finished setting up ~/personalize"
    fi
}

install_buildifier() {
    if command_exists buildifier; then
        _debug "✅ already installed buildifier"
        type buildifier
        return 0
    fi

    _process "🔨 buildifier ${BUILDIFIER_VERSION}"
    buildifier_url="https://github.com/bazelbuild/buildtools/releases/download/v${BUILDIFIER_VERSION}/buildifier-linux-amd64"
    if _download_verified "$buildifier_url" "${HOME}/.bin/buildifier" "$BUILDIFIER_SHA256_LINUX_AMD64"; then
        chmod +x "${HOME}/.bin/buildifier"
        _finished "✅ finished buildifier"
    else
        _finished "⚠️  buildifier: install skipped"
    fi
}

install_buf() {
    if command_exists buf; then
        _debug "✅ already installed buf"
        type buf
        return 0
    fi

    _process "🔨 buf ${BUF_VERSION}"
    buf_os="$(uname -s)"
    buf_arch="$(uname -m)"
    case "${buf_os}-${buf_arch}" in
        Linux-x86_64)   buf_sha256="$BUF_SHA256_LINUX_X86_64" ;;
        Linux-aarch64)  buf_sha256="$BUF_SHA256_LINUX_AARCH64" ;;
        Darwin-x86_64)  buf_sha256="$BUF_SHA256_DARWIN_X86_64" ;;
        Darwin-arm64)   buf_sha256="$BUF_SHA256_DARWIN_ARM64" ;;
        *)              buf_sha256="" ;;
    esac

    buf_url="https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-${buf_os}-${buf_arch}"
    if _download_verified "$buf_url" "${HOME}/.bin/buf" "$buf_sha256"; then
        chmod +x "${HOME}/.bin/buf"
        _finished "✅ finished buf"
    else
        _finished "⚠️  buf: install skipped"
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
