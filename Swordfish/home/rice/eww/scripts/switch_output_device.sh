#!/usr/bin/env bash

stream_ids=($(pactl list short sink-inputs | awk '{print $1}'))

# Loop through all stream IDs and move each to the first output ID
for stream_id in "${stream_ids[@]}"; do
  pactl move-sink-input "$stream_id" "$1"
done


