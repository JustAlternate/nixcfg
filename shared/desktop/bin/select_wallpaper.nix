{ pkgs, ... }:
pkgs.writeShellScriptBin "select_wallpaper" ''
  #!/usr/bin/env bash
  # Set some variables
  wall_dir="$HOME/nixcfg/shared/desktop/wallpaper/"
  cacheDir="$HOME/.cache/jp/"

  # Create cache dir if not exists
  if [ ! -d "$cacheDir" ]; then
    mkdir -p "$cacheDir"
  fi

  physical_monitor_size=24
  monitor_res=$(hyprctl monitors | grep -A2 Monitor | head -n 2 | awk '{print $1}' | grep -oE '^[0-9]+')
  dotsperinch=$(echo "scale=2; $monitor_res / $physical_monitor_size" | bc | xargs printf "%.0f")
  monitor_res=$(($monitor_res * $physical_monitor_size / $dotsperinch))

  rofi_override="element-icon{size:"$monitor_res"px;border-radius:0px;}"

  rofi_command="rofi -wayland -dmenu -theme $HOME/.config/rofi/wall_select.rasi -theme-str $rofi_override"

  # Enable nullglob to ensure that the wildcard pattern expands to an empty list if no matches are found
  shopt -s nullglob

  # Convert images in directory and save to cache dir
  for imagen in "$wall_dir"/*.{jpg,jpeg,png,webp}; do
    if [ -f "$imagen" ]; then
      nombre_archivo=$(basename "$imagen")
      if [ ! -f "$cacheDir/$nombre_archivo" ]; then
        magick "$imagen" -strip -thumbnail 500x500^ -gravity center -extent 500x500 "$cacheDir/$nombre_archivo"
      fi
    fi
  done

  # Select a picture with rofi
  wall_selection=$(find "$wall_dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | shuf | while read -r A; do echo -en "$A\x00icon\x1f""$cacheDir"/"$A\n"; done | $rofi_command)

  # Set the wallpaper
  [[ -n "$wall_selection" ]] || exit 1
  swww img $wall_dir/$wall_selection --transition-step 10 --transition-fps 30 --transition-type center &
  wal -i $wall_dir/$wall_selection &
  sleep 0.2
  killall waybar
  waybar &
  # pywalfox update &
  cp $HOME/.cache/wal/cava_conf $HOME/.config/cava/config &
  [[ $(pidof cava) != "" ]] && pkill -USR1 cava &
  exit 0
''
