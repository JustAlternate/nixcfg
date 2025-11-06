{ lib, config, ... }:

with lib;
{
  options.git = {
    work = {
      enable = mkEnableOption "work git profile";
      description = "Enable work-specific git user name and email.";
    };
  };

  config = mkMerge [
    {
      programs.git = {
        enable = true;
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

    (mkIf (!config.git.work.enable) {
      programs.git = {
        userName = "JustAlternate";
        userEmail = "loicw@justalternate.com";
      };
    })
  ];
}
