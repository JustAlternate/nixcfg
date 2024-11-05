{ pkgs, ... }:
pkgs.writeShellScriptBin "change_wallpaper"
  ''
    file=$(ls /home/justalternate/nixcfg/shared/wallpaper/ | shuf -n 1)
    swww img /home/justalternate/nixcfg/shared/wallpaper/$file --transition-step 10 --transition-fps 30 --transition-type center &
    wal -i /home/justalternate/nixcfg/shared/wallpaper/$file &
    sleep 0.4
    pywalfox update &
    # ~/./.config/conky/update_conky.sh &
    cp ~/.cache/wal/cava_conf ~/.config/cava/config &
    [[ $(pidof cava) != "" ]] && pkill -USR1 cava &
  ''
