{ pkgs, ... }:
let
  # nvidia offload
  nvidia-offload = import ./nvidia-offload.nix pkgs;

  # change wallpaper
  change-wallpaper = import ./change-wallpaper.nix pkgs;
  startup = import ./startup.nix pkgs;
  select-wallpaper = import ./select-wallpaper.nix pkgs;
in
[
  nvidia-offload
  change-wallpaper
  startup
  select-wallpaper
]
