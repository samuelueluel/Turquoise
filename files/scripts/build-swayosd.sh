#!/usr/bin/env bash
# Builds and installs swayosd from source.
# erikreider/swayosd COPR does not publish Fedora 44 builds.
set -euo pipefail

VERSION=$(curl -fsSL "https://api.github.com/repos/ErikReider/SwayOSD/releases/latest" \
  | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
TARBALL_URL="https://github.com/ErikReider/SwayOSD/archive/refs/tags/v${VERSION}.tar.gz"
BUILD_DIR="$(mktemp -d)"
trap "rm -rf '$BUILD_DIR'" EXIT

# Build-time deps (cargo, rust, meson, ninja-build, sassc, gtk4-devel, etc.)
# are pre-installed by the recipe's build-toolchain block.

curl -fsSL --retry 3 --retry-delay 5 "$TARBALL_URL" | tar -xz -C "$BUILD_DIR"

cd "$BUILD_DIR/SwayOSD-${VERSION}"
meson setup build --prefix=/usr --buildtype=release
meson compile -C build
meson install -C build

echo "Done: swayosd ${VERSION}"
