{ pkgs, ... }:
pkgs.writeShellScriptBin "change_wallpaper"
  ''
    file=$(ls /home/justalternate/.config/dotfiles/Laptop/home/rice/wallpaper/ | shuf -n 1)
    swww img /home/justalternate/.config/dotfiles/Laptop/home/rice/wallpaper/$file --transition-step 10 --transition-fps 30 --transition-type center &
    wal -i /home/justalternate/.config/dotfiles/Laptop/home/rice/wallpaper/$file &
    sleep 0.4
    pywalfox update &
    ~/./.config/conky/update_conky.sh &
    themecord &
    cp ~/.cache/wal/cava_conf ~/.config/cava/config &
    [[ $(pidof cava) != "" ]] && pkill -USR1 cava &
  ''
