#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

CODER_USERNAME=${CODER_USERNAME:-}
CODER=${CODER:-}
if test -z "$CODER_USERNAME" && test -z "$CODER"; then
    exit 0
fi

# The apt-packaged direnv ships a stale stdlib (e.g. missing
# dotenv_if_exists), so install the upstream binary into ~/.bin where it
# shadows /usr/bin/direnv on PATH. Guard on the pinned version rather than
# command_exists, since the apt build would otherwise satisfy the check and
# we'd never refresh.
direnv_bin="${HOME}/.bin/direnv"
if test -x "$direnv_bin" && test "$("$direnv_bin" version 2>/dev/null)" = "$DIRENV_VERSION"; then
    _debug "✅ already installed direnv ${DIRENV_VERSION}"
    exit 0
fi

_process "🧭 direnv ${DIRENV_VERSION}"
direnv_os="$(uname -s)"
direnv_arch="$(uname -m)"
case "${direnv_os}-${direnv_arch}" in
    Linux-x86_64)            direnv_asset="linux-amd64";  direnv_sha256="$DIRENV_SHA256_LINUX_AMD64" ;;
    Linux-aarch64)           direnv_asset="linux-arm64";  direnv_sha256="$DIRENV_SHA256_LINUX_ARM64" ;;
    Darwin-x86_64)           direnv_asset="darwin-amd64"; direnv_sha256="$DIRENV_SHA256_DARWIN_AMD64" ;;
    Darwin-arm64)            direnv_asset="darwin-arm64"; direnv_sha256="$DIRENV_SHA256_DARWIN_ARM64" ;;
    *)                       direnv_asset="";             direnv_sha256="" ;;
esac

if test -z "$direnv_asset"; then
    _finished "⚠️  direnv: no asset for ${direnv_os}-${direnv_arch}, install skipped"
    exit 0
fi

direnv_url="https://github.com/direnv/direnv/releases/download/v${DIRENV_VERSION}/direnv.${direnv_asset}"
if _download_verified "$direnv_url" "$direnv_bin" "$direnv_sha256"; then
    chmod +x "$direnv_bin"
    _finished "✅ finished direnv"
else
    _finished "⚠️  direnv: install skipped"
fi
