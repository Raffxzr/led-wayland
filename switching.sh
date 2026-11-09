#!/bin/bash
#
# Toggles the keyboard LEDs by sending SIGUSR1 to the running service.

pid_file=/run/keyboard_leds.pid

# keyboard_leds.sh falls back to the temporary directory when /run is not
# writable (local testing without root).
if [ ! -r "$pid_file" ]
then
    pid_file=${TMPDIR:-/tmp}/keyboard_leds.pid
fi

if [ ! -r "$pid_file" ]
then
    echo "Error: keyboard_leds is not running (no PID file)" >&2
    exit 1
fi

pid=$(cat "$pid_file")

# Ignore a stale PID file left behind by a crashed process.
if [ ! -r "/proc/$pid/cmdline" ] || \
    ! tr '\0' ' ' < "/proc/$pid/cmdline" | grep -q 'keyboard_leds\.sh'
then
    echo "Error: keyboard_leds is not running (stale PID file: $pid_file)" >&2
    exit 1
fi

echo "Keyboard LEDs are switching! (PID: $pid)"

kill -USR1 "$pid"
