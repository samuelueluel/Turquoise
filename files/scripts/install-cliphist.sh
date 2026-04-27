#!/usr/bin/env bash
# Downloads and installs the latest cliphist binary from GitHub releases.
# cliphist is not in Fedora 43 repos; we use the pre-built amd64 binary.
set -euo pipefail

VERSION=$(curl -fsSLI --retry 5 --retry-delay 5 -o /dev/null -w '%{url_effective}' \
  https://github.com/sentriz/cliphist/releases/latest \
  | grep -oP 'v[\d.]+$')
URL="https://github.com/sentriz/cliphist/releases/download/${VERSION}/${VERSION}-linux-amd64"

echo "Installing cliphist ${VERSION}..."

# Must install to /usr/bin/, NOT /usr/local/bin/.
# On Fedora Atomic, /usr/local/ is a writable overlay (/var/usrlocal/)
# and would not be part of the immutable image.
curl -fsSLo /usr/bin/cliphist --retry 5 --retry-delay 5 "$URL"
chmod 755 /usr/bin/cliphist

echo "Done: $(cliphist --version 2>&1 || true)"
