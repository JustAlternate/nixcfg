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
    };
  };
}
