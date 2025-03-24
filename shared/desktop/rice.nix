{ pkgs, ... }:
{
  imports = [
    ./rofi
    ./pywal
    ./hyprland
    ./kitty.nix
    ../fastfetch.nix
  ];

  home.packages = with pkgs; [
    birdtray
    patray
    unrar
    bc
    spacedrive
    fractal
    gcr # for gnome keyring
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
