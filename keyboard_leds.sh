#!/bin/bash
#
# Periodically forces the keyboard backlight LEDs on.
#
# Usage: keyboard_leds.sh [leds_folder] [delay]
#
# SIGUSR1 toggles the LEDs between on and off (see switching.sh).

leds_folder=${1:-/sys/class/leds/}
delay=${2:-0.2}
leds_value=1

# PID file used by switching.sh to find this process. /run is only writable
# by root, so fall back to the temporary directory for local testing.
pid_file=/run/keyboard_leds.pid
if [ ! -w "$(dirname "$pid_file")" ]
then
    pid_file=${TMPDIR:-/tmp}/keyboard_leds.pid
fi
echo $$ > "$pid_file"
trap 'rm -f "$pid_file"' EXIT

sigusr1_handler() {
    if [ "$leds_value" -eq 1 ]
    then
        leds_value=0
    else
        leds_value=1
    fi

    echo "SIGUSR1 received - LEDs value: $leds_value"
}

trap sigusr1_handler SIGUSR1

if [ ! -d "$leds_folder" ]
then
    echo "Error: '$leds_folder' is not a directory" >&2
    exit 1
fi

# Always work with a trailing slash so folder and entry can be concatenated
# safely, no matter how the caller passed the path.
leds_folder=${leds_folder%/}/

while :
do
    # Rescan on every pass so keyboards plugged in after boot are picked up.
    # brightness must be written with '>' (overwrite); '>>' (append) and a
    # preceding sudo (which does not apply to the redirection) do not work.
    shopt -s nullglob
    for led_path in "$leds_folder"*"::scrolllock"/brightness
    do
        [ -f "$led_path" ] || continue

        if ! echo "$leds_value" > "$led_path" 2>/dev/null
        then
            echo "Warning: cannot write to $led_path" >&2
        fi
    done
    shopt -u nullglob

    sleep "$delay"
done
