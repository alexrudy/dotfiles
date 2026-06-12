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

# direnv: https://github.com/direnv/direnv/releases
# Installed on Coder from upstream so the bundled stdlib is current; the
# apt-packaged direnv ships a stale stdlib (e.g. missing dotenv_if_exists).
DIRENV_VERSION="2.37.1"
DIRENV_SHA256_LINUX_AMD64="1f1b93dd6f38523fde26dfac96151ef9d31a374e3005cd3345fb93555ae0c9b5"
DIRENV_SHA256_LINUX_ARM64="2a9cef8d73521d6a3ec3f2871c4b747b8c4cc038628c1b57a7efa42b393a2d82"
DIRENV_SHA256_DARWIN_AMD64="24fb9ce48b563d7e9fbdd3a4e3e836941654a31ce3e67eba9eaafc3dcd8ae73b"
DIRENV_SHA256_DARWIN_ARM64="4f569f3a36732bfd8b8fea7bfcc6ad87a59745c109022164d0ca4832451d5369"
