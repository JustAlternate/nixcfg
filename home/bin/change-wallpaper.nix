{ pkgs, ... }:

pkgs.writeShellScriptBin "change-wallpaper"
  ''
    file=$(ls ~/wallpaper/ | shuf -n 1)
    swww img ~/wallpaper/$file --transition-step 30 --transition-fps 60 --transition-type center &
    wal -i ~/wallpaper/$file &
    sleep 0.1
    eww reload &
    ~/./.config/dotfiles/pywal-discord/pywal-discord &
    cp ~/.cache/wal/cava_conf ~/.config/cava/config &
  ''
