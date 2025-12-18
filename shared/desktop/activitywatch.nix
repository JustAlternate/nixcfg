{ pkgs, ... }:
{
  services = {
    activitywatch = {
      enable = true;
      package = pkgs.aw-server-rust;
      watchers = {
        awatcher = {
          package = pkgs.awatcher;
          settings = {
            poll_time = 3;
          };
        };
      };
    };
  };
}
