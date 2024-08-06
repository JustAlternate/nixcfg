{ config, lib, pkgs, ... }:
{
  import = [
    ./nvim
    ./pywal
    ./hyprland
    ./eww
  ]
}
