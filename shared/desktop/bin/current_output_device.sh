#!/usr/bin/env bash

# Get the default sink ID (output device ID)
default_sink_id=$(pactl info | grep "Default Sink" | awk '{print $3}')

# Get the node_nick (description) of the default sink
node_nick=$(pactl list sinks | grep -A20 "Name: $default_sink_id" | grep "Description" | awk -F'Description: ' '{print $2}')

# Output the description of the default sink
echo "$node_nick"
