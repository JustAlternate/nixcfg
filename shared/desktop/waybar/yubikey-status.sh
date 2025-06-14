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

# Check if YubiKey is present
if lsusb | grep -i "yubikey" > /dev/null; then
    yubikey_status="(inserted)"
else
    yubikey_status="(not present)"
fi

# Output JSON for waybar
if [ "$current_state" = "on" ]; then
    # Check if process is actually running
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" > /dev/null; then
        echo "{\"text\": \"Yubilock: ON $yubikey_status\", \"class\": \"yubilock-on\", \"tooltip\": \"Yubilock enabled $yubikey_status\", \"alt\": \"active\"}"
    else
        # Process died, restart it
				"$SCRIPT_PATH" &
				echo "{\"text\": \"Yubilock: Restarting after dead process\", \"class\": \"yubilock-on\", \"tooltip\": \"Yubilock restarting after dead process $yubikey_status\", \"alt\": \"restarting\"}"

    fi
else
    echo "{\"text\": \"Yubilock: OFF $yubikey_status\", \"class\": \"yubilock-off\", \"tooltip\": \"Yubilock disabled $yubikey_status\", \"alt\": \"inactive\"}"
fi
