#!/bin/bash

set -ouex pipefail

### Remove Bloat/Unused Packages

# Remove Printing/Scanning, GNOME, VLC, and Fingerprint support
rpm-ostree override remove \
    cups \
    cups-browsed \
    cups-filters \
    hplip \
    sane-backends \
    gnome-disk-utility \
    vlc-libs \
    vlc-plugins-base \
    fprintd \
    fprintd-pam \
    || true

# Remove Accessibility Tools
rpm-ostree override remove \
    orca \
    espeak-ng \
    speech-dispatcher \
    || true

# Remove Extra KDE Apps (keep SDDM for display manager)
rpm-ostree override remove \
    kate \
    kwrite \
    konsole-part \
    ark \
    kde-connect \
    plasma-discover \
    plasma-desktop \
    dolphin \
    kwallet \
    kvantum \
    kf5-frameworkintegration \
    kf5-frameworkintegration-libs \
    spectacle \
    systemsettings \
    || true

# Remove Handheld and Emulator Stuff
rpm-ostree override remove \
    hhd \
    rom-properties-kf6 \
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

# Remove Waydroid (Android container support) - including selinux package
rpm-ostree override remove waydroid waydroid-selinux || true

# Remove Emulators (only remove if they exist)
rpm-ostree override remove \
    retroarch \
    snes9x \
    || true

# Remove Btrfs Assistant and Sunshine
rpm-ostree override remove \
    btrfs-assistant \
    sunshine \
    || true



### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# Basic utilities
dnf5 install -y tmux \
    firefox \
    fish \
    fastfetch

### Hyprland Rice Setup

# Enable Hyprland COPR repository
dnf5 -y copr enable solopasha/hyprland

# Core Hyprland components
dnf5 install -y \
    hyprland \
    hyprpaper \
    hypridle \
    hyprlock \
    hyprutils \
    xdg-desktop-portal-hyprland

# Configure SDDM (already installed in base image)
# Create Hyprland session file for SDDM
mkdir -p /usr/share/wayland-sessions
cat > /usr/share/wayland-sessions/hyprland.desktop << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF

# Install SDDM theme dependencies
dnf5 install -y qt6-qt5compat qt6-qtsvg qt6-qtdeclarative

# Download and install Nordic SDDM theme
mkdir -p /usr/share/sddm/themes
curl -L https://github.com/Rokin05/SDDM-Nordic-Darker/archive/refs/heads/main.tar.gz -o /tmp/nordic-theme.tar.gz
tar -xzf /tmp/nordic-theme.tar.gz -C /usr/share/sddm/themes/
mv /usr/share/sddm/themes/SDDM-Nordic-Darker-main /usr/share/sddm/themes/Nordic-Darker
rm /tmp/nordic-theme.tar.gz

# Configure SDDM to use Nordic theme
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/10-theme.conf << 'EOF'
[Theme]
Current=Nordic-Darker
CursorTheme=Adwaita

[General]
InputMethod=
EOF

# Ensure SDDM is enabled
systemctl enable sddm.service

# Status bar & launcher
dnf5 install -y \
    waybar \
    rofi-wayland

# Terminal emulator
dnf5 install -y kitty

# Essential Wayland utilities (removed cliphist, wf-recorder - not in Fedora repos)
dnf5 install -y \
    wl-clipboard \
    grim \
    slurp \
    swappy \
    xdg-utils

# Notifications
dnf5 install -y mako

# System utilities
dnf5 install -y \
    brightnessctl \
    playerctl \
    pavucontrol \
    network-manager-applet \
    blueman \
    lxqt-policykit

# Fonts for rice (these are likely already installed in bazzite-dx, install extra if available)
dnf5 install -y \
    fira-code-fonts \
    jetbrains-mono-fonts-all \
    fontawesome-fonts-all \
    || true

# File manager & viewers
dnf5 -y copr enable lihaohong/yazi
dnf5 install -y \
    imv \
    mpv \
    zathura \
    zathura-pdf-mupdf \
    yazi

# Theme engines
dnf5 install -y \
    qt5ct \
    qt6ct \
    papirus-icon-theme

# Disable all COPRs so they don't end up enabled on the final image
# Check if solopasha/hyprland COPR is enabled before disabling
if dnf5 copr list | grep -q "solopasha/hyprland"; then
    dnf5 -y copr disable solopasha/hyprland
fi
# Check if lihaohong/yazi COPR is enabled before disabling
if dnf5 copr list | grep -q "lihaohong/yazi"; then
    dnf5 -y copr disable lihaohong/yazi
fi

### Deploy User Configuration Files

# Copy skeleton files to /etc/skel for new users
cp -r /ctx/skel/. /etc/skel/

# Set proper permissions
chmod -R 755 /etc/skel/.config

#### System Services

systemctl enable podman.socket

# Set fish as default shell for all users
# First, ensure fish is in /etc/shells (dnf should handle this, but just in case)
grep -q '/usr/bin/fish' /etc/shells || echo '/usr/bin/fish' >> /etc/shells

# Set fish as default shell for root
usermod -s /usr/bin/fish root

# Set fish as the default shell for new users by modifying useradd defaults
sed -i 's|SHELL=.*|SHELL=/usr/bin/fish|' /etc/default/useradd || echo "SHELL=/usr/bin/fish" >> /etc/default/useradd

# Set SHELL environment variable globally
echo "SHELL=/usr/bin/fish" >> /etc/environment



