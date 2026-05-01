#!/usr/bin/env bash
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

CODER_USERNAME=${CODER_USERNAME:-}
CODER=${CODER:-}
if test -z "$CODER_USERNAME" && test -z "$CODER"; then
    exit 0
fi

if command_exists shpool; then
    _debug "✅ already installed shpool"
    exit 0
fi

if ! command_exists cargo; then
    _message "⚠️  shpool: cargo not found, skipping (install rust toolchain first)"
    exit 0
fi

_process "🔨 shpool"
cargo install shpool

systemd_user_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
mkdir -p "$systemd_user_dir"
curl -fsSL -o "${systemd_user_dir}/shpool.service" \
    https://raw.githubusercontent.com/shell-pool/shpool/master/systemd/shpool.service
sed -i "s|/usr|$HOME/.cargo|" "${systemd_user_dir}/shpool.service"
curl -fsSL -o "${systemd_user_dir}/shpool.socket" \
    https://raw.githubusercontent.com/shell-pool/shpool/master/systemd/shpool.socket

systemctl --user enable shpool
systemctl --user start shpool
_finished "✅ installed shpool"
