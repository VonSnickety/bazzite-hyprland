#!/bin/bash

set -ouex pipefail

### Remove Bloat/Unused Packages

# Remove Waydroid (Android container support)
rpm-ostree override remove waydroid || true

# Remove Emulators
rpm-ostree override remove \
    retroarch \
    dolphin-emu \
    pcsx2 \
    duckstation \
    ppsspp \
    cemu \
    snes9x \
    nestopia \
    || true

# Remove VR Support
rpm-ostree override remove \
    monado \
    openxr \
    || true

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# Basic utilities
dnf5 install -y tmux

### Hyprland Rice Setup

# Core Hyprland components
dnf5 install -y \
    hyprland \
    hyprpaper \
    hypridle \
    hyprlock \
    xdg-desktop-portal-hyprland

# Status bar & launcher
dnf5 install -y \
    waybar \
    rofi-wayland

# Terminal emulator
dnf5 install -y kitty

# Essential Wayland utilities
dnf5 install -y \
    wl-clipboard \
    cliphist \
    grim \
    slurp \
    swappy \
    wf-recorder

# Notifications
dnf5 install -y mako

# System utilities
dnf5 install -y \
    brightnessctl \
    playerctl \
    pavucontrol \
    network-manager-applet \
    blueman

# Fonts for rice
dnf5 install -y \
    google-noto-sans-fonts \
    google-noto-serif-fonts \
    google-noto-emoji-fonts \
    fira-code-fonts \
    jetbrains-mono-fonts \
    fontawesome-fonts

# File manager & viewers (using Dolphin from KDE)
dnf5 install -y \
    dolphin \
    imv \
    mpv \
    zathura \
    zathura-pdf-mupdf

# Theme engines
dnf5 install -y \
    qt5ct \
    qt6ct \
    kvantum \
    papirus-icon-theme

#### System Services

systemctl enable podman.socket

### Phrolova Theme Implementation
# Maroon/Red Lycoris color scheme inspired by Phrolova from Wuthering Waves
# Deploy configuration files to /etc/skel

# Copy Phrolova theme configs to /etc/skel
mkdir -p /etc/skel/.config
cp -r /ctx/skel/.config/* /etc/skel/.config/

# Create placeholder for wallpaper
mkdir -p /etc/skel/.config/hypr
cat > /etc/skel/.config/hypr/README-WALLPAPER.md << 'EOF'
# Phrolova Wallpaper Setup

To complete your Phrolova rice, you need to add a wallpaper:

1. Find or create a wallpaper with maroon/red lycoris colors
2. Save it as: ~/.config/hypr/wallpaper.png
3. Recommended resolution: 1920x1080 or higher

**Suggested search terms:**
- "Red lycoris wallpaper"
- "Maroon aesthetic wallpaper"
- "Phrolova Wuthering Waves wallpaper"
- "Dark red flowers wallpaper"

**Temporary solution:**
If you want to test Hyprland without a custom wallpaper:
```bash
# Use a solid color background
echo "preload = " > ~/.config/hypr/hyprpaper.conf
echo "wallpaper = ,#1D0A0E" >> ~/.config/hypr/hyprpaper.conf
```

Or comment out hyprpaper in ~/.config/hypr/hyprland.conf
EOF

echo "Phrolova theme configs deployed to /etc/skel"
