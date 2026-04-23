{ pkgs, ... }:
let
  change_wallpaper = pkgs.writeShellScriptBin "change_wallpaper" ''
    file=$(ls ~/nixcfg/assets/wallpaper/ | shuf -n 1)
    swww img ~/nixcfg/assets/wallpaper/$file --transition-step 10 --transition-fps 30 --transition-type center &
    wal -i ~/nixcfg/assets/wallpaper/$file &
    sleep 0.2
    cp ~/.cache/wal/cava_conf ~/.config/cava/config &
    [[ $(pidof cava) != "" ]] && pkill -USR1 cava &
  '';

  select_wallpaper = pkgs.writeShellScriptBin "select_wallpaper" ''
    wall_dir="$HOME/nixcfg/assets/wallpaper/"
    cacheDir="$HOME/.cache/jp/"

    if [ ! -d "$cacheDir" ]; then
      mkdir -p "$cacheDir"
    fi

    monitor_res=250
    rofi_override="element-icon{size:"$monitor_res"px;border-radius:0px;}"
    rofi_command="rofi -wayland -dmenu -theme $HOME/.config/rofi/wall_select.rasi -theme-str $rofi_override"

    shopt -s nullglob

    for imagen in "$wall_dir"/*.{jpg,jpeg,png,webp}; do
      if [ -f "$imagen" ]; then
        nombre_archivo=$(basename "$imagen")
        if [ ! -f "$cacheDir/$nombre_archivo" ]; then
          magick "$imagen" -strip -thumbnail 250x250^ -gravity center -extent 250x250 "$cacheDir/$nombre_archivo"
        fi
      fi
    done

    wall_selection=$(find "$wall_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | shuf | while read -r A; do echo -en "$A\x00icon\x1f""$cacheDir"/"$A\n"; done | $rofi_command)

    [[ -n "$wall_selection" ]] || exit 1
    swww img $wall_dir/$wall_selection --transition-step 10 --transition-fps 30 --transition-type center &
    wal -i $wall_dir/$wall_selection &
    sleep 0.2
    pkill waybar
    waybar &
    cp $HOME/.cache/wal/cava_conf $HOME/.config/cava/config &
    [[ $(pidof cava) != "" ]] && pkill -USR1 cava &
    exit 0
  '';

  startup = pkgs.writeShellScriptBin "startup" ''
    dunst &
    swww-daemon &

    sudo chmod a+rw /sys/class/backlight/amdgpu_bl1/brightness &

    wl-paste --type text --watch cliphist store &
    wl-paste --type image --watch cliphist store &

    nm-applet --indicator &

    change_wallpaper &

    sleep 0.1
    waybar &
  '';

  switch_audio_output = pkgs.writeShellScriptBin "switch_audio_output" ''
    SINK_LIST=$(pactl list sinks short 2>/dev/null)

    if [ -z "$SINK_LIST" ]; then
        notify-send "Audio Error" "Could not get sink list"
        exit 1
    fi

    SINKS=$(echo "$SINK_LIST" | grep -v "hdmi\|displayport\|dp-" | awk '{print $1}')
    CURRENT_SINK=$(pactl info 2>/dev/null | grep "Default Sink" | awk '{print $3}')
    SINK_ARRAY=($SINKS)

    if [ ''${#SINK_ARRAY[@]} -eq 0 ]; then
        notify-send "Audio Error" "No audio sinks found"
        exit 1
    fi

    CURRENT_INDEX=-1
    for i in "''${!SINK_ARRAY[@]}"; do
        SINK_NAME=$(pactl list sinks short | grep "^''${SINK_ARRAY[$i]}\s" | awk '{print $2}')
        if [ "$SINK_NAME" = "$CURRENT_SINK" ]; then
            CURRENT_INDEX=$i
            break
        fi
    done

    if [ $CURRENT_INDEX -eq -1 ]; then
        NEXT_INDEX=0
    else
        NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ''${#SINK_ARRAY[@]} ))
    fi

    NEXT_SINK=''${SINK_ARRAY[$NEXT_INDEX]}
    NEXT_SINK_NAME=$(pactl list sinks short | grep "^''${NEXT_SINK}\s" | awk '{print $2}')
    pactl set-default-sink "$NEXT_SINK_NAME"

    pactl list sink-inputs short | grep -v "^[[:space:]]*$" | while read -r line; do
        STREAM_ID=$(echo "$line" | awk '{print $1}')
        pactl move-sink-input "$STREAM_ID" "$NEXT_SINK_NAME" 2>/dev/null
    done

    SINK_FRIENDLY=$(pactl list sinks | grep -A 1 "Name: $NEXT_SINK_NAME$" | grep "Description:" | cut -d: -f2 | xargs)
    notify-send "Audio Output" "Switched to: ''${SINK_FRIENDLY:-$NEXT_SINK_NAME}"
  '';
in
{
  home.packages = [
    change_wallpaper
    select_wallpaper
    startup
    switch_audio_output
  ];
}
