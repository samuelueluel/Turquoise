#!/usr/bin/env bash
# Installs Claude Code via the official curl installer, then relocates the
# binary to /usr/bin/. On Fedora Atomic, /usr/local/ is a writable overlay
# at runtime and is NOT part of the immutable image, so any binary left there
# would vanish on deployment.
set -euo pipefail

export HOME=/root

echo "Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash

# Find wherever the installer placed the binary and move it to /usr/bin/
CLAUDE_BIN=$(command -v claude 2>/dev/null || true)

if [[ -z "$CLAUDE_BIN" ]]; then
    # Fallback search in common non-PATH locations
    CLAUDE_BIN=$(find /usr/local/bin /root/.local/bin -name claude 2>/dev/null | head -1 || true)
fi

if [[ -z "$CLAUDE_BIN" ]]; then
    echo "ERROR: claude binary not found after install" >&2
    exit 1
fi

if [[ "$CLAUDE_BIN" != "/usr/bin/claude" ]]; then
    echo "Relocating $CLAUDE_BIN → /usr/bin/claude"
    mv "$CLAUDE_BIN" /usr/bin/claude
    chmod 755 /usr/bin/claude
fi

echo "Done: $(ls -lh /usr/bin/claude)"
