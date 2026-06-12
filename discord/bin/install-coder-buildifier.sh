#!/usr/bin/env sh
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

CODER_USERNAME=${CODER_USERNAME:-}
CODER=${CODER:-}
if test -z "$CODER_USERNAME" && test -z "$CODER"; then
    exit 0
fi

if command_exists buildifier; then
    _debug "✅ already installed buildifier"
    exit 0
fi

_process "🔨 buildifier ${BUILDIFIER_VERSION}"
buildifier_url="https://github.com/bazelbuild/buildtools/releases/download/v${BUILDIFIER_VERSION}/buildifier-linux-amd64"
if _download_verified "$buildifier_url" "${HOME}/.bin/buildifier" "$BUILDIFIER_SHA256_LINUX_AMD64"; then
    chmod +x "${HOME}/.bin/buildifier"
    _finished "✅ finished buildifier"
else
    _finished "⚠️  buildifier: install skipped"
fi
