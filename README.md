# bazzite-hyprland

A minimal Hyprland setup on Bazzite with a Nordic-inspired theme.

## Features

*   **Hyprland Window Manager:** Dynamic tiling Wayland compositor
*   **Waybar:** Customizable status bar
*   **Kitty:** GPU-accelerated terminal
*   **Rofi:** Application launcher and window switcher
*   **Mako:** Notification daemon
*   **Screenshot Tools:** grim, slurp, swappy
*   **Nordic Theme:** Clean, neutral color scheme

## Installation

This image is built on Bazzite. To switch to this image, run the following command:

```bash
sudo bootc switch ghcr.io/vonsnickety/bazzite-hyprland:latest
```

After the command finishes, reboot your system:

```bash
systemctl reboot
```

## Customization

*   **Packages:** Modify `build_files/build.sh` to add or remove packages
*   **Configuration:** Adjust files in `build_files/skel/.config/` for Hyprland, Waybar, Kitty, Rofi, and Mako

## Building Your Own Image

For instructions on building your own custom Bazzite image, see the [official Bazzite documentation](https://universal-blue.org/images/bazzite/building/).