#!/usr/bin/env sh
# shellcheck disable=SC3043,SC2034
set -eu

# Pinned versions and (optional) sha256 checksums for tools downloaded by
# installers. Empty checksum skips verification — fill in when known.
# To get a checksum: `curl -fsSL <url> | sha256sum` (or `shasum -a 256` on mac).

# ripgrep: https://github.com/BurntSushi/ripgrep/releases
RIPGREP_VERSION="14.1.1"
RIPGREP_SHA256_AMD64=""

# buf: https://github.com/bufbuild/buf/releases
BUF_VERSION="1.57.0"
BUF_SHA256_LINUX_X86_64=""
BUF_SHA256_LINUX_AARCH64=""
BUF_SHA256_DARWIN_X86_64=""
BUF_SHA256_DARWIN_ARM64=""

# buildifier: https://github.com/bazelbuild/buildtools/releases
BUILDIFIER_VERSION="6.3.3"
BUILDIFIER_SHA256_LINUX_AMD64=""
