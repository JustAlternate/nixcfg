{ lib, config, pkgs, ... }:

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
      home.packages = [ pkgs.delta ];
      programs.git = {
        enable = true;
        settings = {
          core = {
            pager = "delta";
          };
          interactive = {
            diffFilter = "delta --color-only";
          };
          branch = {
            autoSetupMerge = "simple";
            autoSetupRebase = "always";
          };
          push = {
            autoSetupRemote = true;
            default = "current";
          };
          delta = {
            navigate = true;
            line-numbers = true;
            hyperlinks = true;
            hyperlinks-file-link-format = "file://{path}";
            side-by-side = true;
            inline-hint-style = "syntax";
            file-decoration-style = "bold yellow box ul";
            file-style = "bold yellow ul";
            hunk-header-style = "file line-number";
            hunk-header-decoration-style = "blue box";
            commit-decoration-style = "bold yellow box ul";
            commit-style = "bold yellow ul";
            minus-style = "syntax #340f0f";
            minus-emph-style = "syntax #660000";
            plus-style = "syntax #0f340f";
            plus-emph-style = "syntax #006600";
            keep-plus-minus-markers = true;
            line-numbers-left-style = "red";
            line-numbers-right-style = "green";
            whitespace-error-style = "reverse #500";
            zero-style = "syntax";
          };
          merge = {
            conflictStyle = "zdiff3";
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
