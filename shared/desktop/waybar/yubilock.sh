#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/yubilock-state"
LOG_FILE="$HOME/.cache/yubilock.log"
PID_FILE="$HOME/.cache/yubilock.pid"

# Function to check if a YubiKey is currently plugged in
check_yubikey() {
    if lsusb | grep "1050" > /dev/null; then
        return 0 # device is present
    else
        return 1 # device is not present
    fi
}

# Function to lock the screen
lock_screen() {
    swaylock --config "/home/justalternate/.config/swaylock/config"
    echo "Screen locked at $(date)" >> "$LOG_FILE"
}

# Create state file if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo "on" > "$STATE_FILE"
fi

# Record PID for later termination
echo "$$" > "$PID_FILE"

# Main monitoring loop
echo "YubiKey monitoring started at $(date)" >> "$LOG_FILE"

while true; do
    # Check if monitoring is still enabled
    if [ "$(cat "$STATE_FILE")" != "on" ]; then
        echo "YubiKey monitoring stopped at $(date)" >> "$LOG_FILE"
        exit 0
    fi

    if check_yubikey; then
        echo "YubiKey detected at $(date)" >> "$LOG_FILE"

        # Wait until the YubiKey is removed
        while check_yubikey && [ "$(cat "$STATE_FILE")" = "on" ]; do
            sleep 1
        done

        # If we exited because service was disabled, exit gracefully
        if [ "$(cat "$STATE_FILE")" != "on" ]; then
            echo "YubiKey monitoring stopped at $(date)" >> "$LOG_FILE"
            exit 0
        fi

        echo "YubiKey removed at $(date)" >> "$LOG_FILE"
        lock_screen
    else
        echo "No YubiKey detected. Checking again in 10 seconds..." >> "$LOG_FILE"
        # Check less frequently to reduce system load
        sleep 10
    fi
done
