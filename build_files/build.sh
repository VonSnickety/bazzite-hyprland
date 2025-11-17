#!/bin/bash

set -ouex pipefail

### Remove Bloat/Unused Packages

# Remove Printing/Scanning
rpm-ostree override remove \
    cups \
    cups-browsed \
    cups-filters \
    hplip \
    sane-backends \
    iscan \
    xsane \
    bluez-cups \
    || true

# Remove GNOME utilities
rpm-ostree override remove \
    gnome-disk-utility \
    || true

# Remove VLC
rpm-ostree override remove \
    vlc-libs \
    vlc-plugins-base \
    || true

# Remove Accessibility Tools
rpm-ostree override remove \
    orca \
    espeak-ng \
    speech-dispatcher \
    brltty \
    || true

# Remove Fingerprint support
rpm-ostree override remove \
    fprintd \
    fprintd-pam \
    || true

# Remove Handheld Hardware Support and Gaming Device Stuff
rpm-ostree override remove \
    hhd \
    hhd-ui \
    adjustor \
    powerbuttond \
    jupiter-fan-control \
    steam-powerbuttond \
    steamdeck-kde-presets \
    chimera \
    || true

# Remove GameScope (handheld/Steam Deck session)
rpm-ostree override remove \
    gamescope \
    gamescope-session-plus \
    gamescope-session-steam \
    || true

# Remove Emulators - ALL OF THEM
rpm-ostree override remove \
    retroarch \
    retroarch-assets \
    retroarch-filters \
    retroarch-overlays \
    snes9x \
    dolphin-emu \
    pcsx2 \
    ppsspp \
    rpcs3 \
    cemu \
    duckstation \
    mgba \
    mupen64plus \
    redream \
    emudeck \
    retrodeck \
    rom-properties-kf6 \
    pegasus-frontend \
    || true

# Remove all libretro cores
rpm-ostree override remove \
    libretro-* \
    || true

# Remove Gaming Launchers (keep Steam and Lutris only)
rpm-ostree override remove \
    heroic-games-launcher \
    bottles \
    || true

# Remove Gaming Tools/Plugins (keep essentials like MangoHud, GameMode)
rpm-ostree override remove \
    decky-loader \
    discover-overlay \
    protonup-qt \
    || true

# Remove Streaming/Recording Software
rpm-ostree override remove \
    obs-studio \
    obs-vkcapture \
    sunshine \
    moonlight-qt \
    || true

# Remove Waydroid (Android container support)
rpm-ostree override remove \
    waydroid \
    waydroid-selinux \
    || true

# Remove Fcitx5 and Input Remapper
rpm-ostree override remove \
    fcitx5 \
    fcitx5-mozc \
    fcitx5-chinese-addons \
    fcitx5-hangul \
    kcm-fcitx5 \
    input-remapper \
    || true

# Remove Btrfs Assistant (unless you specifically use Btrfs snapshots)
rpm-ostree override remove \
    btrfs-assistant \
    || true

# Remove Hyprland and tiling WM components (switching to KDE)
rpm-ostree override remove \
    hyprland \
    hyprpaper \
    hypridle \
    hyprlock \
    hyprutils \
    xdg-desktop-portal-hyprland \
    waybar \
    rofi-wayland \
    mako \
    || true

# Remove extra KDE apps we don't want (we'll install minimal KDE below)
rpm-ostree override remove \
    kate \
    kwrite \
    konsole-part \
    kde-connect \
    plasma-discover \
    kwallet \
    kvantum \
    kf5-frameworkintegration \
    kf5-frameworkintegration-libs \
    || true


### Install Essential Packages

# Basic utilities
dnf5 install -y --skip-broken \
    tmux \
    firefox \
    fastfetch

### Install Minimal KDE Plasma Desktop

# Core KDE Plasma components
dnf5 install -y \
    plasma-desktop \
    plasma-workspace \
    plasma-systemsettings \
    kwin \
    kwin-wayland \
    kscreen \
    powerdevil \
    plasma-pa \
    plasma-nm \
    bluedevil

# Minimal KDE Applications (only essentials)
dnf5 install -y \
    dolphin \
    konsole \
    ark \
    spectacle

# KDE Integration
dnf5 install -y \
    kde-gtk-config \
    plasma-integration \
    xdg-desktop-portal-kde

# Ensure SDDM is installed and configured for KDE
dnf5 install -y sddm

# Create KDE Plasma Wayland session file for SDDM
mkdir -p /usr/share/wayland-sessions
cat > /usr/share/wayland-sessions/plasmawayland.desktop << 'EOF'
[Desktop Entry]
Name=Plasma (Wayland)
Comment=KDE Plasma Wayland session
Exec=/usr/bin/startplasma-wayland
TryExec=/usr/bin/startplasma-wayland
Type=Application
DesktopNames=KDE
X-KDE-PluginInfo-Version=6.0
EOF

# Configure SDDM for Wayland session
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/10-wayland.conf << 'EOF'
[General]
InputMethod=

[Wayland]
SessionDir=/usr/share/wayland-sessions
EOF

# Ensure SDDM is enabled
systemctl enable sddm.service

### System Services

# Enable podman socket (useful for containers)
systemctl enable podman.socket

# Set graphical target
systemctl set-default graphical.target


### Deploy User Configuration Files

# Copy skeleton files to /etc/skel for new users
# Note: Most Hyprland configs will be removed, KDE uses its own defaults
cp -r /ctx/skel/. /etc/skel/ || true

# Set proper permissions
chmod -R 755 /etc/skel/.config 2>/dev/null || true

