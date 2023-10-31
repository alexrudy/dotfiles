fpath=($DOTFILES/onepassword/functions $fpath)
autoload -U $DOTFILES/onepassword/functions/*(:t)

OP_CONTAINER="${HOME}/Library/Group Containers/2BUA8C4S2C.com.1password/"

if test -S "${OP_CONTAINER}/t/agent.sock"; then
    if test ! -e "${HOME}/.1password/agent.sock"; then
        ln -s "${OP_CONTAINER}/t/agent.sock" "${HOME}/.1password/agent.sock"
    fi
    export SSH_AUTH_SOCK="${HOME}/.1password/agent.sock"
fi
