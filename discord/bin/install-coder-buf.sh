#!/usr/bin/env bash
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

CODER_USERNAME=${CODER_USERNAME:-}
CODER=${CODER:-}
if test -z "$CODER_USERNAME" && test -z "$CODER"; then
    exit 0
fi

if command_exists buf; then
    _debug "✅ already installed buf"
    exit 0
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
