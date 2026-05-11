#!/usr/bin/env bash
# Builds and installs wlctl (formerly impala-nm) from source via git clone.
set -euo pipefail

# Build-time deps (cargo, rust, git) are pre-installed by the recipe's build-toolchain block.

echo "Building wlctl from source..."
WORK_DIR="$(mktemp -d)"
trap "rm -rf '$WORK_DIR'" EXIT

cd "$WORK_DIR"
git clone https://github.com/aashish-thapa/wlctl
cd wlctl

# Build the release binary
cargo build --release

# Install directly to /usr/bin/
install -Dm755 target/release/wlctl /usr/bin/wlctl

echo "wlctl installed successfully."
