#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

RIPGREP_VERSION="14.1.1"

install_ripgrep_deb() {
    rg_arch="$(dpkg --print-architecture)"
    case "$rg_arch" in
        amd64) ;;
        *)
            _message "⚠️  ripgrep: no prebuilt deb for arch ${rg_arch}, skipping"
            return 0
            ;;
    esac

    rg_deb="ripgrep_${RIPGREP_VERSION}-1_${rg_arch}.deb"
    rg_url="https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/${rg_deb}"

    _process "🏄 Install ripgrep ${RIPGREP_VERSION} (${rg_arch})"
    workdir="$(mktemp -d)"
    trap 'rm -rf "$workdir"' EXIT INT TERM

    if curl -fsSL -o "${workdir}/${rg_deb}" "$rg_url"; then
        sudo dpkg -i "${workdir}/${rg_deb}"
        _finished "✅ Installed ripgrep"
    else
        _finished "⚠️  ripgrep: failed to download ${rg_url}"
    fi

    rm -rf "$workdir"
    trap - EXIT INT TERM
}

install_ripgrep() {
    if command_exists rg; then
        return 0
    fi

    if command_exists dpkg && command_exists curl; then
        install_ripgrep_deb
        return 0
    fi

    if command_exists brew; then
        _process "🏄 Install ripgrep"
        brew install ripgrep
        _finished "✅ Installed ripgrep"
    fi
}

install_ripgrep
