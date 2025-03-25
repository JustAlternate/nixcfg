{ lib, config, ... }:
with lib;
{
  options.git = {
    work = {
      enable = mkEnableOption "work git profile";
    };
  };

  config = mkMerge [
    {
      programs.git = {
        enable = true;
        userName = "JustAlternate";
        userEmail = "loicw@justalternate.fr";
        extraConfig = {
          branch = {
            autoSetupMerge = "simple";
            autoSetupRebase = "always";
          };
          push = {
            autoSetupRemote = true;
            default = "current";
          };
        };
      };
    }

    (mkIf config.git.work.enable {
      programs.git = {
        userName = "JustAlternateIDZ";
        userEmail = "loic.weber@iadvize.com";
      };
    })
  ];
}
