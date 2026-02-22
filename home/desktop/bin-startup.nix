{ pkgs, ... }:
pkgs.writeShellScriptBin "startup" ''
  dunst &
  swww-daemon &

  # Unlock brightness control
  sudo chmod a+rw /sys/class/backlight/amdgpu_bl1/brightness &

  wl-paste --type text --watch cliphist store &
  wl-paste --type image --watch cliphist store &

  nm-applet --indicator &

  change_wallpaper &

  sleep 0.1
  waybar &
''
