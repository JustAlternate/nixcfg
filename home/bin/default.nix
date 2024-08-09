{ pkgs, ... }:
let
  # nvidia offload
  nvidia_offload = import ./nvidia-offload.nix pkgs;

  # change wallpaper
  change_wallpaper = import ./change-wallpaper.nix pkgs;
  startup = import ./startup.nix pkgs;
  select_wallpaper = import ./select-wallpaper.nix pkgs;
in
[
  nvidia_offload
  change_wallpaper
  startup
  select_wallpaper
]
