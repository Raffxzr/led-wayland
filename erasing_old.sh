#!/bin/bash
#
# Removes files installed by older versions of this project.

if [ "$(id -u)" -ne 0 ]
then
    echo "Error: run this script as root (sudo ./erasing_old.sh)" >&2
    exit 1
fi

for old_file in \
    /usr/local/bin/keyboard_leds.sh \
    /usr/local/bin/keyboard_switch.sh \
    /etc/systemd/system/keyboard_leds.service \
    /etc/sudoers.d/leds_wayland \
    /etc/sudoers.d/led_wayland
do
    if [ -f "$old_file" ]
    then
        echo "Old file detected: $old_file"
        echo "Erasing file"
        rm -f "$old_file"
    fi
done
