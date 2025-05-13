{ pkgs, ... }:
{
  home.packages = [
    pkgs.pgcli
    pkgs.mycli
  ];

  xdg.configFile."pgcli/config".source = ./config;

  home = {
    file = {
      ".myclirc".source = ./.myclirc;
    };
    sessionVariables = {
      PGCLIRC = "$HOME/.config/pgcli/config";
      MYCLIRC = "$HOME/.myclirc";
    };
  };
}
