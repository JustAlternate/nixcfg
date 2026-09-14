{ pkgs, ... }:
let
  desktopInfra = import ./packages/desktop-infra.nix { inherit pkgs; };
  browsers = import ./packages/browsers.nix { inherit pkgs; };
  communication = import ./packages/communication.nix { inherit pkgs; };
  productivity = import ./packages/productivity.nix { inherit pkgs; };
  media = import ./packages/media.nix { inherit pkgs; };
  gaming = import ./packages/gaming.nix { inherit pkgs; };
in
{
  imports = [
    ./shell
    ./cli
    ./dev
    ./desktop
    ../modules/home/git.nix
    ../modules/home/ssh.nix
  ];

  home.packages = desktopInfra ++ browsers ++ communication ++ productivity ++ media ++ gaming;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "librewolf.desktop";
      "application/xhtml+xml" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
      "x-scheme-handler/about" = "librewolf.desktop";
      "x-scheme-handler/unknown" = "librewolf.desktop";
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    NIX_AUTO_RUN = 1;
  };

  programs.home-manager.enable = true;
}
