{pkgs, ...}:
pkgs.writeShellScriptBin "change_wallpaper"
''
  file=$(ls ~/wallpaper/ | shuf -n 1)
  swww img ~/wallpaper/$file --transition-step 10 --transition-fps 30 --transition-type center &
  wal -i ~/wallpaper/$file &
  sleep 0.4
  pywalfox update &
  ~/./.config/conky/update_conky.sh &
  cp ~/.cache/wal/discord-pywal.css ~/.config/vesktop/themes/pywal.css &
  cp ~/.cache/wal/cava_conf ~/.config/cava/config &
  [[ $(pidof cava) != "" ]] && pkill -USR1 cava &
''
