#!/usr/bin/env bash
# Builds and installs cclip from source.
set -euo pipefail

# Build-time deps (meson, ninja-build, gcc, wayland-devel, sqlite-devel, xxhash-devel)
# are pre-installed by the recipe's build-toolchain block.

echo "Building cclip..."
WORK_DIR="$(mktemp -d)"
trap "rm -rf '$WORK_DIR'" EXIT

cd "$WORK_DIR"
git clone --depth 1 https://github.com/heather7283/cclip
cd cclip

# Setup meson build
meson setup --buildtype=release build
meson compile -C build

# Install directly to /usr/bin/
install -Dm755 build/cclip /usr/bin/cclip
install -Dm755 build/cclipd /usr/bin/cclipd

echo "cclip installed successfully."
