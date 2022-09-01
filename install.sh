#!/bin/sh

if [[ -z "$CODER_USERNAME" ]]; then
    source `dirname $0`/install-discord.sh
fi

python3 `dirname $0`/install.py --mode=S