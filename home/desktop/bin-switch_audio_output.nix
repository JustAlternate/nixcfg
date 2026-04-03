{ pkgs, ... }:
pkgs.writeShellScriptBin "switch_audio_output" ''
  # Switch between audio outputs (excluding HDMI/DisplayPort monitors)

  # Get list of all sinks using pactl (more reliable parsing)
  SINK_LIST=$(pactl list sinks short 2>/dev/null)

  if [ -z "$SINK_LIST" ]; then
      notify-send "Audio Error" "Could not get sink list"
      exit 1
  fi

  # Filter out HDMI and DisplayPort sinks, keep only lines with valid sinks
  SINKS=$(echo "$SINK_LIST" | grep -v "hdmi\|displayport\|dp-" | awk '{print $1}')

  # Get current default sink
  CURRENT_SINK=$(pactl info 2>/dev/null | grep "Default Sink" | awk '{print $3}')

  # Convert sink numbers to array
  SINK_ARRAY=($SINKS)

  if [ ${#SINK_ARRAY[@]} -eq 0 ]; then
      notify-send "Audio Error" "No audio sinks found"
      exit 1
  fi

  # Find current sink index
  CURRENT_INDEX=-1
  for i in "${!SINK_ARRAY[@]}"; do
      SINK_NAME=$(pactl list sinks short | grep "^${SINK_ARRAY[$i]}\s" | awk '{print $2}')
      if [ "$SINK_NAME" = "$CURRENT_SINK" ]; then
          CURRENT_INDEX=$i
          break
      fi
  done

  # If current sink not found, start from beginning
  if [ $CURRENT_INDEX -eq -1 ]; then
      NEXT_INDEX=0
  else
      # Get next sink
      NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#SINK_ARRAY[@]} ))
  fi

  NEXT_SINK=${SINK_ARRAY[$NEXT_INDEX]}

  # Get sink name for pactl
  NEXT_SINK_NAME=$(pactl list sinks short | grep "^${NEXT_SINK}\s" | awk '{print $2}')

  # Switch to next sink
  pactl set-default-sink "$NEXT_SINK_NAME"

  # Move all playing streams to new sink
  pactl list sink-inputs short | grep -v "^[[:space:]]*$" | while read -r line; do
      STREAM_ID=$(echo "$line" | awk '{print $1}')
      pactl move-sink-input "$STREAM_ID" "$NEXT_SINK_NAME" 2>/dev/null
  done

  # Get friendly name for notification
  SINK_FRIENDLY=$(pactl list sinks | grep -A 1 "Name: $NEXT_SINK_NAME$" | grep "Description:" | cut -d: -f2 | xargs)

  # Send notification
  notify-send "Audio Output" "Switched to: ${SINK_FRIENDLY:-$NEXT_SINK_NAME}"
''
