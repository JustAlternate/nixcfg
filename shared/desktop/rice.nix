{ pkgs, inputs, ... }:
{
  imports = [
    ../fastfetch
    ./rofi
    ./pywal
    ./hyprland
    ./kitty.nix
    ./gonixvim.nix
  ];

  home.packages = with pkgs; [
    birdtray
    patray
    unrar
  ];

  home.sessionVariables = {
    XCURSOR_THEME = "Numix-Cursor";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Numix-Cursor";
    HYPRCURSOR_SIZE = "24";
  };

  #qt = {
  #  enable = true;
  #  platformTheme.name = "gtk2";
  #  style.name = "gtk2";
  #};

  # gtk = {
  #   enable = true;
  #   iconTheme = {
  #     name = "Reversal";
  #     package = pkgs.reversal-icon-theme;
  #   };

  #   cursorTheme = {
  #     name = "Numix-Cursor";
  #     package = pkgs.numix-cursor-theme;
  #   };
  # };
}
