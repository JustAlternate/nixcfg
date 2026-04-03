{ lib, config, ... }:
with lib;
{
  options.ssh.work.enable = mkEnableOption "work ssh profile";
  config = mkMerge [
    {
      programs.ssh = {
        enable = true;
        matchBlocks = {
          "beaver" = {
            # justalternate.com
            hostname = "195.201.116.51";
            user = "root";
            identityFile = "~/.ssh/id_ed25519";
            addKeysToAgent = "yes";
          };
          "geckoNixos1" = {
            # RPI3b+
            hostname = "192.168.1.11";
            user = "root";
            port = 22;
            identityFile = "~/.ssh/id_ed25519";
            addKeysToAgent = "yes";
          };
          "geckoNixos2" = {
            # RPI4B
            hostname = "192.168.1.12";
            user = "root";
            port = 22;
            identityFile = "~/.ssh/id_ed25519";
            addKeysToAgent = "yes";
          };
          "geckoNixos3" = {
            # RPI4B
            hostname = "192.168.1.13";
            user = "root";
            port = 22;
            identityFile = "~/.ssh/id_ed25519";
            addKeysToAgent = "yes";
          };
          "geckoNixos4" = {
            # RPI4B
            hostname = "192.168.1.14";
            user = "root";
            port = 22;
            identityFile = "~/.ssh/id_ed25519";
            addKeysToAgent = "yes";
          };
          "geckoNixosRemote1" = {
            # RPI3b+ via beaver (tailscale)
            hostname = "100.64.0.0";
            user = "root";
            port = 22;
            identityFile = "~/.ssh/id_ed25519";
            addKeysToAgent = "yes";
            proxyJump = "beaver";
          };
          "ocelot" = {
            #batocera
            hostname = "192.168.1.242";
            user = "root";
            identityFile = "~/.ssh/id_ed25519";
            port = 22;
            addKeysToAgent = "yes";
          };
          "github.com" = {
            user = "git";
            identityFile = "~/.ssh/id_ed25519";
            forwardAgent = true;
            addKeysToAgent = "yes";
          };
        };
      };
    }
    (mkIf config.ssh.work.enable {
      programs.ssh = {
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
    })
  ];
}
