#!/usr/bin/env bash

# Start the Eww window definition
cat <<EOF
(defwindow mic_dropdown
  :monitor 0
  :name "mic_dropdown"
  :stacking "fg"
  :exclusive true
  :geometry (geometry :x "1500px" :y "5px" :width "100px" :height "100px")
  :anchor "top right"
  (box
    :class "mic-dropdown"
    :orientation "vertical"
EOF

# Generate buttons for each output device
outputs_ids=($(pactl list short sinks | awk '{print $1}'))

for output_id in "${outputs_ids[@]}"; do
  node_nick=$(pactl list sinks | grep -A20 "Sink #$output_id" | grep "Description" | awk -F': ' '{print $2}')
  echo "    (button :onclick \"scripts/switch_output_device.sh $output_id\" \"$node_nick\")"
done

# Close the box and window definition
cat <<EOF
  )
)
EOF
