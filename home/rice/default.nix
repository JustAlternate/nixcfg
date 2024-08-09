{ config, lib, pkgs, ... }:
{
  imports = [
    ./pywal
    ./hyprland
    ./eww
    ./rofi
  ];

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos_small";
        padding = {
          right = 1;
        };
      };

      display = {
        binaryPrefix = "si";
        color = "blue";
        separator = "  ";
      };

      modules = [
        "host"
        "os"
        "uptime"
        "cpu"
        "memory"
        "colors"
      ];
    };
  };
}
