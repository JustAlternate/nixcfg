#!/usr/bin/env bash

# Generate buttons for each output device
outputs_ids=($(pactl list short sinks | awk '{print $1}'))

for output_id in "${outputs_ids[@]}"; do
	node_nick=$(pactl list sinks | grep -A20 "Sink #$output_id" | grep "Description" | awk -F': ' '{print $2}')
	echo "$node_nick"
done
