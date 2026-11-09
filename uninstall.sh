#!/bin/bash
#
# Uninstalls the keyboard LEDs service, its files and its sudoers rule.

set -euo pipefail

if [ "$(id -u)" -ne 0 ]
then
    echo "Error: run this script as root (sudo ./uninstall.sh)" >&2
    exit 1
fi

echo "Uninstalling LED's routines and services..."

systemctl stop keyboard_leds 2>/dev/null || true
systemctl disable keyboard_leds 2>/dev/null || true

# Removing all routines.
rm -rf /opt/led-wayland

# Removing the systemd service.
rm -f /etc/systemd/system/keyboard_leds.service

# Removing user permissions (both current and legacy file names).
rm -f /etc/sudoers.d/leds_wayland /etc/sudoers.d/led_wayland

# Reloading services - forcing initialization.
systemctl daemon-reload

echo "Done!"
echo "LEDs routines uninstalled"
