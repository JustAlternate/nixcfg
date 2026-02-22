{ pkgs, ... }:
let
  desktopCore = import ./packages/desktop.nix { inherit pkgs; };
  productivity = import ./packages/productivity.nix { inherit pkgs; };
  media = import ./packages/media.nix { inherit pkgs; };
  gaming = import ./packages/gaming.nix { inherit pkgs; };
in
{
  imports = [
    ./shell
    ./dev
    ./desktop
    ../modules/git.nix
    ../modules/ssh.nix
  ];

  home.packages =
    desktopCore ++ productivity ++ media ++ gaming ++ (import ./desktop/bin.nix { inherit pkgs; });

  home.sessionVariables = {
    EDITOR = "nvim";
    NIX_AUTO_RUN = 1;
  };

  programs.home-manager.enable = true;
}
