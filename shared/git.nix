{ pkgs, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  home.packages = with pkgs; [
    lazygit
  ];

  programs.git = {
    enable = true;
    userName = "JustAlternate";
    userEmail = "loicw@justalternate.fr";
    extraConfig = {
      branch = {
        # Automatic remote tracking.
        autoSetupMerge = mkDefault "simple";
        # Automatically use rebase for new branches.
        autoSetupRebase = mkDefault "always";
      };
      push = {
        autoSetupRemote = true;
        default = mkDefault "simple";
      };
    };
  };
}
