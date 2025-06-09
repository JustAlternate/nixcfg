#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/yubilock-state"
PID_FILE="$HOME/.cache/yubilock.pid"
SCRIPT_PATH="$HOME/nixcfg/shared/desktop/waybar/yubilock.sh"

# Create state file if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo "on" > "$STATE_FILE"
fi

# Read current state
current_state=$(cat "$STATE_FILE")

# Toggle state
sleep 1
if [ "$current_state" = "on" ]; then
    # Turn off monitoring
    notify-send "Yubilock is shutting down" -e
    echo "off" > "$STATE_FILE"
    # Kill the monitoring process if it's running
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if kill -0 "$pid" > /dev/null; then
            kill "$pid"
        fi
    fi
    echo '{"text": "Yubilock: OFF", "class": "yubilock-off", "tooltip": "Yubilock disabled"}'
else
    # Turn on monitoring
    echo "on" > "$STATE_FILE"
    # Start the monitoring script
    notify-send "Yubilock is now starting" -e
    "$SCRIPT_PATH" &
    echo '{"text": "Yubilock: ON", "class": "yubilock-on", "tooltip": "Yubilock enabled"}'
fi
