{ pkgs, ... }:
let
  # change wallpaper
  change_wallpaper = import ./change_wallpaper.nix pkgs;
  select_wallpaper = import ./select_wallpaper.nix pkgs;
  startup = import ./startup.nix pkgs;
in
[
  change_wallpaper
  select_wallpaper
  startup
]
