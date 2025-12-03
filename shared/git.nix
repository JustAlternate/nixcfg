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
        settings = {
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
        settings = {
          user = {
            name = "JustAlternateIDZ";
            email = "loic.weber@iadvize.com";
          };
        };
      };
    })

    (mkIf (!config.git.work.enable) {
      programs.git = {
        settings = {
          user = {
            name = "JustAlternate";
            email = "loicw@justalternate.com";
          };
        };
      };
    })
  ];
}
