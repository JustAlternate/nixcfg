{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Launchers
    rofi
  ];
  xdg = {
    configFile = {
      "rofi/bottom_large.rasi".source = ./themes/bottom_large.rasi;
      "rofi/wall_select.rasi".source = ./themes/wall_select.rasi;
      "rofi/bemoji.rasi".source = ./themes/bemoji.rasi;
      "rofi/config.rasi".source = ./themes/config.rasi;
    };
  };
}
