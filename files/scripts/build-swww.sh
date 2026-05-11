#!/usr/bin/env bash
# Builds and installs swww (swww + swww-daemon binaries) from source.
# swww is not in Terra for Fedora 44 and ships no pre-built binaries.
set -euo pipefail

API_URL="https://api.github.com/repos/LGFae/swww/releases/latest"
BUILD_DIR="$(mktemp -d)"
trap "rm -rf '$BUILD_DIR'" EXIT

VERSION=$(curl -fsSL --retry 5 --retry-delay 5 "$API_URL" | grep '"tag_name"' | cut -d'"' -f4)
TARBALL_URL="https://github.com/LGFae/swww/archive/refs/tags/${VERSION}.tar.gz"

echo "Building swww ${VERSION}..."

curl -fsSL --retry 5 --retry-delay 5 "$TARBALL_URL" | tar -xz -C "$BUILD_DIR"

cd "$BUILD_DIR/swww-${VERSION#v}"
cargo build --release

# Must install to /usr/bin/, NOT /usr/local/bin/.
# On Fedora Atomic, /usr/local/ is a writable overlay (/var/usrlocal/)
# and would not be part of the immutable image.
install -Dm755 target/release/swww      /usr/bin/swww
install -Dm755 target/release/swww-daemon /usr/bin/swww-daemon

echo "Done: $(swww --version)"
