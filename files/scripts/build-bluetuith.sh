#!/usr/bin/env bash
# Builds and installs the latest bluetuith from source.
# bluetuith is not in Fedora repos or Homebrew; built with Go toolchain.
set -euo pipefail

API_URL="https://api.github.com/repos/darkhz/bluetuith/releases/latest"
WORK_DIR="$(mktemp -d)"
trap "rm -rf '$WORK_DIR'" EXIT

CURL_AUTH=()
[[ -n "${GITHUB_TOKEN:-}" ]] && CURL_AUTH=(-H "Authorization: Bearer $GITHUB_TOKEN")

VERSION=$(curl -fsSL --retry 5 --retry-delay 5 "${CURL_AUTH[@]}" "$API_URL" | grep '"tag_name"' | cut -d'"' -f4)
echo "Building bluetuith ${VERSION}..."

cd "$WORK_DIR"
curl -fsSL --retry 5 --retry-delay 5 "${CURL_AUTH[@]}" "https://github.com/darkhz/bluetuith/archive/refs/tags/${VERSION}.tar.gz" \
  | tar -xz
cd "bluetuith-${VERSION#v}"

go build -o bluetuith .

# Must install to /usr/bin/, NOT /usr/local/bin/.
# On Fedora Atomic, /usr/local/ is a writable overlay (/var/usrlocal/)
# and would not be part of the immutable image.
install -Dm755 bluetuith /usr/bin/bluetuith

echo "Done: bluetuith ${VERSION}"
