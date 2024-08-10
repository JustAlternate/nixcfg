{ pkgs, ... }:

pkgs.writeShellScriptBin "startup"
  ''
    dunst &
    # Change wallpaper and use wall to change the theme
    swww-daemon &
    change-wallpaper &
    eww daemon &
    eww open --screen $(( $(hyprctl monitors | grep -c "Monitor") - 1 )) hbar &

    # Unlock brightness control
    sudo chmod a+rw /sys/class/backlight/amdgpu_bl1/brightness &

    wl-paste --type text --watch cliphist store &
    wl-paste --type image --watch cliphist store &
    nm-applet --indicator &
    conky &
  ''
