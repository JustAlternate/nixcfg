{ pkgs, ... }:
pkgs.writeShellScriptBin "change_wallpaper"
  ''
    file=$(ls ./../rice/wallpaper/ | shuf -n 1)
    swww img ./../rice/wallpaper/$file --transition-step 10 --transition-fps 30 --transition-type center &
    wal -i ./../rice/wallpaper/$file &
    sleep 0.4
    pywalfox update &
    ~/./.config/conky/update_conky.sh &
    themecord &
    cp ~/.cache/wal/cava_conf ~/.config/cava/config &
    [[ $(pidof cava) != "" ]] && pkill -USR1 cava &
  ''
