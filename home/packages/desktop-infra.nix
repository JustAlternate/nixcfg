{ pkgs, ... }:
with pkgs;
[
  awww
  libnotify
  brightnessctl
  grim
  slurp
  hyprland-protocols
  hyprcursor
  pwvucontrol
  pulseaudio
  networkmanagerapplet
  networkmanager
  pkgs.thunar
  pkgs.thunar-volman
  bluez
  blueman
  playerctl
]
