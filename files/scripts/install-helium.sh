#!/usr/bin/env bash
set -euo pipefail

echo "Installing Helium Browser (AppImage)..."

# 1. Fetch latest release metadata from GitHub API
RELEASE_DATA=$(curl -fsSL --retry 3 --retry-delay 5 https://api.github.com/repos/imputnet/helium-linux/releases/latest)
URL=$(echo "$RELEASE_DATA" | grep "browser_download_url" | grep "x86_64.AppImage" | cut -d '"' -f 4 | head -n 1)
VERSION=$(echo "$RELEASE_DATA" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$URL" ]; then
    echo "Error: Could not find Helium AppImage URL for x86_64."
    exit 1
fi

# 2. Download AppImage to /usr/bin/helium
echo "Downloading Helium $VERSION..."
curl -fsSL --retry 3 --retry-delay 5 -o /usr/bin/helium "$URL"
chmod +x /usr/bin/helium

# 3. Setup Icon
# Using the high-res branding icon from the main repo
ICON_DIR="/usr/share/icons/hicolor/scalable/apps"
mkdir -p "$ICON_DIR"
curl -fsSL --retry 3 --retry-delay 5 -o "$ICON_DIR/helium.png" "https://raw.githubusercontent.com/imputnet/helium/main/resources/branding/app_icon/raw.png"

# 4. Create Desktop File for launcher integration (fuzzel, etc.)
cat <<EOF > /usr/share/applications/helium.desktop
[Desktop Entry]
Name=Helium
GenericName=Web Browser
Comment=Privacy-focused web browser based on Ungoogled Chromium
Exec=/usr/bin/helium %u
Icon=helium
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF

echo "Helium $VERSION installed successfully."
