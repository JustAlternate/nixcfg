_:
{
  programs.zsh.profileExtra =
    ''
      [[ $(tty) == /dev/tty1 ]]&&exec Hyprland
    '';
}
