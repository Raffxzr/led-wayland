#!/bin/bash
#
# Installs the keyboard LEDs control service for Wayland.

set -euo pipefail

if [ "$(id -u)" -ne 0 ]
then
    echo "Error: run this script as root (sudo ./install.sh)" >&2
    exit 1
fi

install_dir=/opt/led-wayland
service_file=/etc/systemd/system/keyboard_leds.service
sudoers_file=/etc/sudoers.d/leds_wayland

echo "Installing LEDs control for Wayland"

# Stops the task if it is already running.
systemctl stop keyboard_leds 2>/dev/null || true

# Copy repository contents to the 'opt' system directory.
echo "Copying repository to $install_dir"
install -d -m 0755 "$install_dir"
cp -a -- ./* "$install_dir"/

# The service runs these files as root, so they must not keep the owner of the
# user who cloned the repository (that would allow privilege escalation).
chown -R root:root "$install_dir"
find "$install_dir" -type f -exec chmod 0644 {} +
chmod 0755 "$install_dir"/*.sh
echo "Repository copied"

# Uninstall an older version, if it exists.
"$install_dir/erasing_old.sh"

# Systemd service - initializes routine after boot.
install -m 0644 "$install_dir/keyboard_leds.service" "$service_file"

# Allows the invoking user to toggle the LEDs without a password.
# The rule is limited to switching.sh instead of every command.
target_user=${SUDO_USER:-$(id -un)}
printf '%s ALL=(root) NOPASSWD: %s\n' "$target_user" "$install_dir/switching.sh" > "$sudoers_file"
chmod 0440 "$sudoers_file"
if command -v visudo >/dev/null 2>&1
then
    visudo -cf "$sudoers_file"
fi
# Removes the overly broad rule written by older versions.
rm -f /etc/sudoers.d/led_wayland

# Enables auto-init.
systemctl daemon-reload
systemctl enable keyboard_leds
systemctl start keyboard_leds

echo "Done!"
echo ""
echo "Now the LEDs should turn on automatically"
echo "To turn off LEDs or turn on again execute:"
echo "sudo $install_dir/switching.sh"
