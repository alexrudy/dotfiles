#!/usr/bin/env bash
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

# Coder-specific apt packages (separate from the generic apt-install
# list in apt/packages/). Stored alongside other discord/ config so
# that the generic apt installer in apt/ stays Coder-agnostic.

CODER_USERNAME=${CODER_USERNAME:-}
CODER=${CODER:-}
if test -z "$CODER_USERNAME" && test -z "$CODER"; then
    exit 0
fi

if ! command_exists apt-get; then
    exit 0
fi

CODER_APT_INSTALL="${DOTFILES}/discord/apt-install.txt"
if ! test -f "$CODER_APT_INSTALL"; then
    exit 0
fi

_process "📦 coder apt packages"

echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
export DEBIAN_FRONTEND=noninteractive

sudo apt-get --quiet update -y > /dev/null

PACKAGES=$(tr '\n' ' ' < "$CODER_APT_INSTALL")
# shellcheck disable=SC2086
sudo apt-get --quiet install --no-install-recommends -y ${PACKAGES} > /dev/null

_finished "✅ finished coder apt packages"
