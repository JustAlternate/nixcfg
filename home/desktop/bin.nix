{ pkgs, ... }:
let
  # change wallpaper
  change_wallpaper = import ./bin-change_wallpaper.nix pkgs;
  select_wallpaper = import ./bin-select_wallpaper.nix pkgs;
  startup = import ./bin-startup.nix pkgs;
in
[
  change_wallpaper
  select_wallpaper
  startup
]
