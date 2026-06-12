#!/usr/bin/env sh
# Install the pr-reviews systemd user timer + service. Only runs on the
# `base` Coder workspace — other workspaces (feature branches, throwaway)
# shouldn't run the sweep.
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

CODER_USERNAME=${CODER_USERNAME:-}
CODER=${CODER:-}
CODER_WORKSPACE_NAME=${CODER_WORKSPACE_NAME:-}

if test -z "$CODER_USERNAME" && test -z "$CODER"; then
    exit 0
fi

if [ "$CODER_WORKSPACE_NAME" != "base" ]; then
    _debug "⏭  not on base workspace (CODER_WORKSPACE_NAME=${CODER_WORKSPACE_NAME:-unset}), skipping pr-reviews timer"
    exit 0
fi

if ! command_exists systemctl; then
    _message "⚠️  pr-reviews-timer: systemctl not found, skipping"
    exit 0
fi

systemd_user_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
mkdir -p "$systemd_user_dir"

needs_reload=""
for unit in pr-reviews.service pr-reviews.timer; do
    src="${DOTFILES}/discord/systemd/${unit}"
    dst="${systemd_user_dir}/${unit}"
    if [ -L "$dst" ] && [ "$(_realpath "$dst")" = "$(_realpath "$src")" ]; then
        _debug "✅ ${unit} already linked"
    elif [ -e "$dst" ]; then
        _message "⚠️  ${unit} would conflict with existing file at ${dst}"
        exit 0
    else
        _process "🔗 linking ${unit}"
        ln -s "$src" "$dst"
        needs_reload="1"
        _finished "✅ ${unit} linked"
    fi
done

if [ -n "$needs_reload" ]; then
    _process "🔄 reloading systemd user units"
    systemctl --user daemon-reload
    _finished "✅ systemd reloaded"
fi

if ! systemctl --user is-enabled pr-reviews.timer >/dev/null 2>&1; then
    _process "⏰ enabling pr-reviews.timer"
    systemctl --user enable --now pr-reviews.timer
    _finished "✅ pr-reviews.timer enabled"
else
    _debug "✅ pr-reviews.timer already enabled"
fi
