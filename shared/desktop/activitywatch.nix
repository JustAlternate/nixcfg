{ pkgs, ... }:
{
  services.activitywatch = {
    enable = true;
    watchers = {
      aw-watcher-afk = {
        package = pkgs.activitywatch;
        settings = {
          timeout = 300;
          poll_time = 2;
        };
      };
      aw-watcher-window = {
        package = pkgs.aw-watcher-window;
        settings = {
          poll_time = 1;
        };
      };
    };
  };
}
