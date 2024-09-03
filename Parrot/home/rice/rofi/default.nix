{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Launchers
    rofi-wayland
  ];
  xdg = {
    configFile = {
      "rofi/bottom_large.rasi".source = ./bottom_large.rasi;
      "rofi/wall_select.rasi".source = ./wall_select.rasi;
      "rofi/bemoji.rasi".source = ./bemoji.rasi;
      "rofi/config.rasi".source = ./config.rasi;
    };
  };
}
