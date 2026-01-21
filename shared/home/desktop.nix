{ pkgs, ... }:
let
  desktopCore = import ../packages/desktop-core.nix { inherit pkgs; };
  productivity = import ../packages/productivity.nix { inherit pkgs; };
  media = import ../packages/media.nix { inherit pkgs; };
  gaming = import ../packages/gaming.nix { inherit pkgs; };
in
{
  imports = [
    ../shell
    ../ssh.nix
    ../git.nix
    ../desktop/dev
    ../desktop
  ];

  desktop.enable = true;

  xdg.configFile."hypr/pyprland.json".source = ../desktop/hyprland/pyprland.json;

  home.packages =
    desktopCore ++ productivity ++ media ++ gaming ++ (import ../desktop/bin { inherit pkgs; });

  home.sessionVariables = {
    EDITOR = "nvim";
    NIX_AUTO_RUN = 1;
  };

  programs.home-manager.enable = true;
}
