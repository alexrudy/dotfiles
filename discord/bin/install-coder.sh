#!/usr/bin/env bash
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

# Coder/Discord OS-level setup. Per-tool installers (buf, buildifier,
# shpool) live alongside this file as install-coder-*.sh and run as
# independent installers via run_installers, so a single binary download
# outage no longer blocks the whole Coder bootstrap.

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

envrc_links() {
    discord_root="${HOME}/dev/discord/discord/"
    if ! test -d "${discord_root}.git"; then
        _debug "⏭️  discord monorepo not at ${discord_root}, skipping .envrc links"
        return 0
    fi
    _process "🔗 linking .envrc files into discord monorepo"
    bash "${DOTFILES}/discord/direnv/setup.sh" "${discord_root}"
    _finished "✅ finished linking .envrc files"
}

CODER_USERNAME=${CODER_USERNAME:-}
CODER=${CODER:-}

if test ! -z "$CODER_USERNAME" || test ! -z "$CODER" ; then
    # Discord-specific installation steps

    _process "👾 Coder Specific Install Steps"

    personalize

    envrc_links

    # github_cli

    _finished "✅ Coder Specific Install Steps"
fi
