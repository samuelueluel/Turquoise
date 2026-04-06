#!/usr/bin/env bash
# Installs Gemini CLI globally via npm.
# Uses --prefix /usr so the binary lands in /usr/bin/ (not /usr/local/bin/,
# which is a writable overlay on Fedora Atomic and won't be baked into the image).
set -euo pipefail

echo "Installing @google/gemini-cli..."
npm install -g --prefix /usr @google/gemini-cli

echo "Done: $(gemini --version)"
