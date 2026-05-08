#!/usr/bin/env bash
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

# Generic GitHub CLI installer for apt-based Linux. Adds the upstream
# apt repo and installs gh. Used everywhere apt-get is available; not
# Coder-specific.
if ! command_exists apt-get; then
    exit 0
fi

if command_exists gh; then
    _debug "✅ already installed gh"
    exit 0
fi

_process "🐙 github cli"

echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
export DEBIAN_FRONTEND=noninteractive

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    sudo dd status=none of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
    sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

sudo apt-get --quiet update -y > /dev/null
sudo apt-get --quiet install --no-install-recommends -y gh > /dev/null

_finished "✅ finished github cli"
