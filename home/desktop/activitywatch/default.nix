{ pkgs, ... }:
{
  services.activitywatch = {
    enable = true;
    package = pkgs.unstable.aw-server-rust;
    watchers = {
      awatcher = {
        package = pkgs.awatcher;
        settings = {
          idle-timeout-seconds = 180;
          poll-time-idle-seconds = 4;
          poll-time-window-seconds = 1;
        };
      };
    };
  };
}
