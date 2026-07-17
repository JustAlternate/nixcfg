{ lib, config, ... }:
with lib;
{
  options.ssh.work.enable = mkEnableOption "work ssh profile";
  config = mkMerge [
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          "beaver" = {
            Hostname = "195.201.116.51";
            User = "root";
            IdentityFile = "~/.ssh/id_ed25519";
            AddKeysToAgent = "yes";
          };
          "geckoNixos1" = {
            Hostname = "100.64.0.1";
            User = "root";
            Port = 22;
            IdentityFile = "~/.ssh/id_ed25519";
            AddKeysToAgent = "yes";
          };
          "geckoNixos2" = {
            Hostname = "100.64.0.3";
            User = "root";
            Port = 22;
            IdentityFile = "~/.ssh/id_ed25519";
            AddKeysToAgent = "yes";
          };
          "geckoNixos3" = {
            Hostname = "100.64.0.4";
            User = "root";
            Port = 22;
            IdentityFile = "~/.ssh/id_ed25519";
            AddKeysToAgent = "yes";
          };
          "geckoNixos4" = {
            Hostname = "100.64.0.5";
            User = "root";
            Port = 22;
            IdentityFile = "~/.ssh/id_ed25519";
            AddKeysToAgent = "yes";
          };
          "ocelot" = {
            Hostname = "192.168.1.242";
            User = "root";
            IdentityFile = "~/.ssh/id_ed25519";
            Port = 22;
            AddKeysToAgent = "yes";
          };
          "github.com" = {
            User = "git";
            IdentityFile = "~/.ssh/id_ed25519";
            ForwardAgent = "yes";
            AddKeysToAgent = "yes";
          };
        };
      };
    }
    (mkIf config.ssh.work.enable {
      programs.ssh.settings = {
        "github.com" = {
          IdentityFile = mkForce "~/.ssh/mac_id_ed25519";
          IdentitiesOnly = "yes";
        };
        "*.iadvize.net" = {
          User = "iadvize";
        };
        "10.62.*.*" = {
          StrictHostKeyChecking = "no";
          IdentityFile = "~/.ssh/mac_id_ed25519";
        };
      };
    })
  ];
}
