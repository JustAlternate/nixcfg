{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  programs.git = {
    enable = true;
    userName = "JustAlternate";
    userEmail = "cat /run/secrets/EMAIL";
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
