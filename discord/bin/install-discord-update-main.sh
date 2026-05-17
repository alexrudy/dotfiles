#!/usr/bin/env sh
# Install the com.discord.update-main launch agent: symlink the plist into
# ~/Library/LaunchAgents and (re)load it via launchctl. macOS only; skipped on
# Coder/Linux hosts where launchd is unavailable.
set -eu

# shellcheck source=../../installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

if [ "$(uname -s)" != "Darwin" ]; then
    exit 0
fi

if [ -n "${CODER_USERNAME:-}" ] || [ -n "${CODER:-}" ]; then
    exit 0
fi

PLIST_SRC="${DOTFILES}/discord/com.discord.update-main.plist"
PLIST_DST="${HOME}/Library/LaunchAgents/com.discord.update-main.plist"
LABEL="com.discord.update-main"
DOMAIN="gui/$(id -u)"

mkdir -p "$(dirname "$PLIST_DST")"

needs_reload=""
if [ -L "$PLIST_DST" ] && [ "$(_realpath "$PLIST_DST")" = "$(_realpath "$PLIST_SRC")" ]; then
    _debug "✅ ${LABEL} already linked"
elif [ -e "$PLIST_DST" ]; then
    _message "⚠️  ${LABEL} would conflict with existing file at ${PLIST_DST}"
    exit 0
else
    _process "🔗 linking ${LABEL}"
    ln -s "$PLIST_SRC" "$PLIST_DST"
    needs_reload="1"
    _finished "✅ ${LABEL} linked"
fi

if ! launchctl print "${DOMAIN}/${LABEL}" >/dev/null 2>&1; then
    needs_reload="1"
fi

if [ -n "$needs_reload" ]; then
    _process "🚀 loading ${LABEL}"
    launchctl bootout "${DOMAIN}/${LABEL}" >/dev/null 2>&1 || true
    launchctl bootstrap "$DOMAIN" "$PLIST_DST"
    _finished "✅ ${LABEL} loaded"
fi
