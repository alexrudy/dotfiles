
#: Build the install script
build:
    python installers/build.py

#: Check that this can work with a basic set of installed libraries.
docker-check: build
    docker run -e DOTFILES='~/.dotfiles/' --rm python sh -c "$(cat install.sh)"

#: Check that we can install dotfiles in a basic environment with curl
docker-check-curl: build
    docker run -e DOTFILES='~/.dotfiles/' --rm curlimages/curl sh -c "$(cat install.sh)"
