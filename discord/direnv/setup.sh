add_envrc() {
    DISCORD_ROOT="${1:-${HOME}/dev/discord/discord}"
    if ! test -d "$DISCORD_ROOT/.git"; then
        echo "Have you set up the discord monorepo?"
        exit 1
    fi

    HERE=$(realpath "$(dirname "$0")")

    ENVRCS=$(find "$HERE" -name envrc)

    for ENVRC in $ENVRCS; do
        TARGET="${DISCORD_ROOT}${ENVRC#${HERE}}"
        TARGET="${TARGET%envrc}.envrc"
        if ! test -f $TARGET; then
            if ln -s "$ENVRC" "$TARGET"; then
                echo "Linked $ENVRC to $TARGET"
            fi
        else
            echo "Skipping $TARGET, already exists"
        fi
    done
}

add_envrc "$@"
