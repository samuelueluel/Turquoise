#!/usr/bin/env bash

set -ouex pipefail

echo "Baking dotfiles snapshot from public repo..."

DOTFILES_OWNER="${DOTFILES_OWNER:-samuelueluel}"
git clone --depth=1 "https://github.com/${DOTFILES_OWNER}/dotfiles.git" /usr/share/turquoise/dotfiles
rm -rf /usr/share/turquoise/dotfiles/.git

echo "Copying fallback configs to /etc..."
mkdir -p /etc/niri

# Niri fallback (handle potential .tmpl extension)
if [[ -f "/usr/share/turquoise/dotfiles/dot_config/niri/config.kdl" ]]; then
    cp /usr/share/turquoise/dotfiles/dot_config/niri/config.kdl /etc/niri/config.kdl
elif [[ -f "/usr/share/turquoise/dotfiles/dot_config/niri/config.kdl.tmpl" ]]; then
    cp /usr/share/turquoise/dotfiles/dot_config/niri/config.kdl.tmpl /etc/niri/config.kdl
    sed -i 's/{{ .chezmoi.homeDir }}/\$HOME/g' /etc/niri/config.kdl
fi
chmod +x \
    /usr/bin/sjust \
    /usr/bin/niri-complement-column \
    /usr/bin/niri-minimap \
    /usr/bin/niri-nav \
    /usr/bin/niri-mode-toggle \
    /usr/bin/niri-shader \
    /usr/bin/niri_parse_keybinds.py \
    /usr/bin/niri-tile-toggle \
    /usr/bin/smart-close.sh
