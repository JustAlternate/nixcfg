#!/usr/bin/env bash

# Get the current default sink description (node_nick)
current_device=$(./scripts/current_output_device.sh)

# Get the list of output device descriptions (node_nick) and IDs
outputs_ids=($(pactl list short sinks | awk '{print $1}'))
outputs_descriptions=()

for output_id in "${outputs_ids[@]}"; do
	node_nick=$(pactl list sinks | grep -A20 "Sink #$output_id" | grep "Description" | awk -F': ' '{print $2}')
	outputs_descriptions+=("$node_nick")
done

# Find the index of the current device in the list
current_index=-1
for i in "${!outputs_descriptions[@]}"; do
	if [[ "${outputs_descriptions[$i]}" == "$current_device" ]]; then
		current_index=$i
		break
	fi
done

# If current device not found, exit (shouldn't happen)
if [[ $current_index -eq -1 ]]; then
	echo "Current device not found in the list." >>/tmp/switch_log.txt
	exit 1
fi

# Get the index of the next device (wrap around if necessary)
next_index=$(((current_index + 1) % ${#outputs_descriptions[@]}))

# Switch all streams to the next output device
next_output_id=${outputs_ids[$next_index]}
stream_ids=($(pactl list short sink-inputs | awk '{print $1}'))

for stream_id in "${stream_ids[@]}"; do
	pactl move-sink-input "$stream_id" "$next_output_id"
done

# Set the default sink to the next device
pactl set-default-sink "$next_output_id"

# Log the switching action
echo "Switched to: ${outputs_descriptions[$next_index]} (ID: $next_output_id)" >>/tmp/switch_log.txt
