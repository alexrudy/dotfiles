#!/bin/sh

if [ -n "$CODER_USERNAME" ]; then
    . `dirname $0`/install-discord.sh
fi

python3 `dirname $0`/install.py --mode=M
