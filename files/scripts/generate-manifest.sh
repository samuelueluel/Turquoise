#!/usr/bin/env bash
# This script runs at the end of the BlueBuild image build process.
# It probes key packages and records their versions into a manifest file.
set -uo pipefail

MANIFEST="/usr/share/samuel-niri/manifest.md"
mkdir -p "$(dirname "$MANIFEST")"

{
    echo "# samuel-niri Image Manifest"
    echo "Build Date: $(date -u +'%Y-%m-%d %H:%M UTC')"
    echo ""
    echo "## Key Package Versions"
} > "$MANIFEST"

get_ver() {
    local name="$1"
    local cmd="$2"
    local ver="Unknown"
    
    if command -v "$cmd" &>/dev/null; then
        # Use a subshell to safely try various version flags without crashing the script
        # Some GUI apps (like Zen or Niri) might exit with 1 even on --version in headless CI
        ver=$( ($cmd --version 2>&1 || $cmd -v 2>&1 || $cmd --help 2>&1 || echo "Error") | head -n1 )
        echo "- **$name**: $ver" >> "$MANIFEST"
    else
        echo "- **$name**: (Not found in image)" >> "$MANIFEST"
    fi
}

# Run probes - errors here shouldn't kill the build
get_ver "Niri" "niri"
get_ver "Yazi" "yazi"
get_ver "Zed" "zed"
get_ver "Alacritty" "alacritty"
get_ver "Kitty" "kitty"
get_ver "Zen Browser" "zen-browser"
get_ver "Helium" "helium"
get_ver "mpd" "mpd"
get_ver "rmpc" "rmpc"
get_ver "Nemo" "nemo"
get_ver "Chezmoi" "chezmoi"
get_ver "Just" "just"

echo "- **Kernel**: Vanilla Stable (see recipe)" >> "$MANIFEST"

echo "Manifest generated at $MANIFEST"
