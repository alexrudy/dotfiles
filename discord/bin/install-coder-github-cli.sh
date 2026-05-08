#!/usr/bin/env bash
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

CODER_USERNAME=${CODER_USERNAME:-}
CODER=${CODER:-}
if test -z "$CODER_USERNAME" && test -z "$CODER"; then
    exit 0
fi

if command_exists gh; then
    _debug "✅ already installed gh"
    exit 0
fi

_process "🐙 github cli apt repo"

echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
export DEBIAN_FRONTEND=noninteractive

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd status=none of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
_finished "✅ finished github cli apt repo"
