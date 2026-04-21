#!/usr/bin/env bash
# Downloads and installs the latest cliphist binary from GitHub releases.
# cliphist is not in Fedora 43 repos; we use the pre-built amd64 binary.
set -euo pipefail

API_URL="https://api.github.com/repos/sentriz/cliphist/releases/latest"

VERSION=$(curl -fsSL "$API_URL" | grep '"tag_name"' | cut -d'"' -f4)
URL="https://github.com/sentriz/cliphist/releases/download/${VERSION}/${VERSION}-linux-amd64"

echo "Installing cliphist ${VERSION}..."

# Must install to /usr/bin/, NOT /usr/local/bin/.
# On Fedora Atomic, /usr/local/ is a writable overlay (/var/usrlocal/)
# and would not be part of the immutable image.
curl -fsSLo /usr/bin/cliphist "$URL"
chmod 755 /usr/bin/cliphist

echo "Done: $(cliphist --version 2>&1 || true)"
