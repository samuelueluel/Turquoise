# First-Time Setup Guide

!! If someone besides me ever reads this: obviously all this may not apply to you. !!

---

## 1. Before formatting

Save your SSH keys to Bitwarden as secure notes to ensure you can clone your private repositories on the new system.

```bash
cat ~/.ssh/id_ed25519      # Copy this → Bitwarden secure note: "SSH Private Key"
cat ~/.ssh/id_ed25519.pub  # Copy this → Bitwarden secure note: "SSH Public Key"
```

Include the full content, including header and footer lines for the private key. You'll retrieve these from bitwarden.com on first boot using Zen Browser.

---

## 2. Install Fedora Silverblue 

During the Fedora Silverblue installer:
- **Filesystem:** Choose **XFS**.
- **User Account:** Set username to **`samuel`** (crucial, as Niri/Chezmoi configs have hardcoded `/home/samuel/` paths).
- **Network:** Connect to WiFi during install.

**Secure Boot:** Disable Secure Boot in BIOS firmware before rebooting into the custom image. The image uses the `@kernel-vanilla/stable` upstream kernel, which cannot be signed for Secure Boot.

---

## 3. Image Rebase

After the first boot into stock Silverblue, open a terminal and rebase to the custom image.

```bash
bootc switch ghcr.io/samuelueluel/samuel-niri:latest
systemctl reboot
```

This pulls the full image. After reboot, you will land at the **gtkgreet** login screen, which starts **Niri**.

---

## 4. Initial Environment Setup

Niri starts with built-in defaults until dotfiles are applied.
- **Terminal:** Press **`Super+T`** to open Alacritty.
- **WiFi:** If not connected, run `nmtui`.
- **File browsing:** Use **Nemo** for any file browsing at this stage. Yazi depends on Homebrew CLI tools that aren't available until step 6, so search and previews won't work correctly beforehand.

### Restore SSH Keys
Open Zen Browser, log into bitwarden.com, and restore your keys:

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh

# Paste private key content (include header/footer lines):
nano ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519

# Paste public key content:
nano ~/.ssh/id_ed25519.pub
chmod 644 ~/.ssh/id_ed25519.pub

# Verify connection
ssh -T git@github.com
```

---

## 5. Repository Cloning

Clone the three core repositories that define the system.

```bash
git clone git@github.com:samuelueluel/samuel-niri.git ~/samuel-niri
git clone git@github.com:samuelueluel/dotfiles.git ~/dotfiles
git clone git@github.com:samuelueluel/system_config_git.git ~/system_config_git
```

---

## 6. Automated Configuration

Run the setup script to automate the bulk of the user-level configuration.

```bash
bash ~/samuel-niri/setup-dotfiles.sh
```

**What this script handles:**
- **Dotfiles:** Deploys via `chezmoi apply`, pre-creating all required directories.
- **Zsh:** Clones Powerlevel10k and fzf-tab plugins, then sets Zsh as the default shell.
- **Zen Browser:** Creates `personal`, `utility`, and `work` profiles and restores settings (keybindings, themes, `user.js`) from `system_config_git/zen/`.
- **Claude Code + Gemini CLI:** Restores `settings.json` for both from `system_config_git/`.
- **Dev Tools:** Installs Homebrew packages from `~/.Brewfile`.
- **Flatpak Overrides:** Grants Quod Libet and pwvucontrol read access to GTK theme config for Noctalia theming.
- **Systemd user services:** Enables `empty-trash`, `battery-notify`, and `cliphist-wipe`.

**Log out and back in** after the script completes to activate the new shell and inject Homebrew into the systemd user session PATH.

---

## 7. Manual Polish & Authentication

### Application Authentication
```bash
claude   # browser-based login
gemini   # browser OAuth
dropbox start -i  # sign in via tray
```

### Zen Browser — Manual Steps
Settings, keybindings, and mods are restored automatically by the setup script. Extensions must be installed manually in each profile. Custom extensions are in `system_config_git`.

### Manual Config Restoration
Some application data is too large or specific for Chezmoi/automation:

- **Wallpapers:**
  ```bash
  cp -r ~/system_config_git/Wallpapers ~/Pictures/Wallpapers
  ```

---

## 8. Post-Setup System Configuration

### Swap (16GB Swap File)

By default, Fedora uses an 8GB zRAM device. Replace it with a 16GB file on `/var` for workloads that need more physical swap space.

Check current swap status first:
```bash
swapon --show
```
If you see `/dev/zram0`, zRAM is active. If you see `/var/swapfile`, it's already set up.

To create the swap file:

1. **Disable zRAM:**
   ```bash
   sudo touch /etc/systemd/zram-generator.conf
   sudo swapoff /dev/zram0
   ```

2. **Create and activate the swap file:**
   ```bash
   sudo fallocate -l 16G /var/swapfile
   sudo chmod 600 /var/swapfile
   sudo mkswap /var/swapfile
   sudo swapon /var/swapfile
   ```

3. **Persist across reboots** — add to `/etc/fstab` if not already present:
   ```text
   /var/swapfile none swap defaults 0 0
   ```

Verify:
```bash
swapon --show
```

---

## 9. System Reference: Noctalia Theme

**Noctalia** is the custom system-wide color palette. It is applied per-application via Chezmoi-managed config files.

| Component | Config Location |
|---|---|
| **GTK 3/4** | `~/.config/gtk-x.0/gtk.css` (imports `noctalia.css`) |
| **Alacritty** | `~/.config/alacritty/themes/noctalia.toml` |
| **Kitty** | `~/.config/kitty/kitty.conf` |
| **Zed** | `~/.config/zed/themes/noctalia.json` |
| **Qt 5/6** | `~/.config/qtXct/colors/noctalia.conf` |
| **Claude Code** | Uses `dark-ansi` (inherits terminal palette) |
| **Gemini CLI** | Hand-crafted `AlacrittyCompatible` theme |

**Flatpaks:** If a new GTK Flatpak is added, it needs permission to read the theme files:
```bash
flatpak override --user --filesystem=xdg-config/gtk-3.0:ro <app-id>
```
Once verified, add the override to `setup-dotfiles.sh`.

Qt/KDE Flatpaks are much more annoying. Use kvantum?
