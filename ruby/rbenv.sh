if command_exists brew; then
    export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
fi

if command_exists rbenv; then
    eval "$(rbenv init -)"
fi