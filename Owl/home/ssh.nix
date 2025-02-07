{ lib, ... }:
let
  inherit (lib) mkForce;
in
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    forwardAgent = true;
    matchBlocks = {
      "github.com" = {
        identityFile = mkForce "~/.ssh/mac_id_ed25519";
      };
      "*.iadvize.net" = {
        user = "iadvize";
      };
      "10.62.*.*" = {
        identityFile = mkForce "~/.ssh/mac_id_ed25519";
      };
    };
  };
}
