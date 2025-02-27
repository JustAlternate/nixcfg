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
    };
    extraConfig = ''
      Host 10.62.*.*
      StrictHostKeyChecking no
      IdentityFile ~/.ssh/mac_id_ed25519
    '';
  };
}
