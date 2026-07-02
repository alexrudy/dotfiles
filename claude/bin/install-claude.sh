#!/usr/bin/env bash
set -eu

# shellcheck source=installers/prelude.sh
. "${DOTFILES}/installers/prelude.sh"

# Link personal Claude Code config into ~/.claude.
#
# The repo-wide *.symlink / *.dir conventions flatten to ~/.<name>, so they
# can't target nested paths like ~/.claude/CLAUDE.md or ~/.claude/skills/<name>.
# And ~/.claude holds Claude Code runtime state (credentials, history,
# sessions), so we link individual items in rather than the directory itself —
# which also lets machine-local skills/commands coexist with the shared ones.
#
# Public, non-sensitive config lives under claude/. Anything personal (skills or
# commands that embed identities, channel IDs, colleague names, etc.) lives in
# the private submodule at claude/private/ so it never lands in this public repo.
# Both trees link into the same ~/.claude/{skills,commands}.

# Symlink $1 (a file or dir in this repo) to $2 (an absolute path under
# ~/.claude). Idempotent: skips if already linked correctly; replaces a stale
# symlink; backs up a real file/dir to <target>.backup before linking.
link_claude_path() {
    local src target shortname
    src="$1"
    target="$2"
    shortname="${target#"${HOME}/"}"

    if test -L "$target" && test "$(_realpath "$target")" = "$(_realpath "$src")"; then
        _debug "✅ ${shortname} already linked"
        return 0
    fi

    mkdir -p "$(dirname "$target")"

    if test -L "$target"; then
        rm -f "$target"                     # stale symlink — nothing to preserve
    elif test -e "$target"; then
        mv "$target" "${target}.backup"     # real file/dir — keep a backup
        _message "⚠️  backed up existing ${shortname} to ${shortname}.backup"
    fi

    ln -s "$(_realpath "$src")" "$target"
    _message "✅ linked ${shortname} → ${src#"${HOME}/"}"
}

# Link every child of claude/<$1> into ~/.claude/<$2>, one symlink per entry (so
# public, private, and machine-local entries coexist). No-op when the source dir
# is absent — e.g. the private submodule isn't checked out on this machine.
link_claude_children() {
    local srcsub dstsub entry name
    srcsub="$1"
    dstsub="$2"
    test -d "${DOTFILES}/claude/${srcsub}" || return 0
    for entry in "${DOTFILES}/claude/${srcsub}"/*; do
        test -e "$entry" || continue
        name="$(basename "$entry")"
        link_claude_path "$entry" "${HOME}/.claude/${dstsub}/${name}"
    done
}

_process "🤖 linking Claude Code config"
link_claude_path "${DOTFILES}/claude/CLAUDE.md" "${HOME}/.claude/CLAUDE.md"
link_claude_children "skills"           "skills"     # public, non-sensitive
link_claude_children "commands"         "commands"   # public, non-sensitive
link_claude_children "private/skills"   "skills"     # private submodule
link_claude_children "private/commands" "commands"   # private submodule
_finished "✅ Claude Code config linked"
