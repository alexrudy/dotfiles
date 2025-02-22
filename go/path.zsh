if [ -d "$HOME/.go" ]; then
    export GOPATH=~/.go
    export GOBIN=~/.go/bin
    export GOSRC=~/.go/src/
    pathadd $GOBIN
fi
