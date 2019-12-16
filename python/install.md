# Installing Python

## pyenv

```
git clone https://github.com/pyenv/pyenv.git ~/.pyenv

git clone https://github.com/momo-lab/xxenv-latest.git "$(pyenv root)"/plugins/xxenv-latest
git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv

```

## ubuntu

```
sudo apt-get install git python-pip make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libffi-dev
```

## Getting pyenv to install things on macOS

```
SDKROOT=$(xcode-select -p)/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.15.sdk \
MACOSX_DEPLOYMENT_TARGET=10.15
```