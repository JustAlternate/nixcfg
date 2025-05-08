{ pkgs, ... }:
{
  imports = [
    ./rofi
    ./waybar
    ./pywal
    ./hyprland
    ./kitty.nix
    ../fastfetch.nix
  ];

  # TODO: FIX THIS

  home.packages = with pkgs; [
    birdtray
    patray
    unrar
    bc
    spacedrive
    fractal

    gcr # for gnome keyring

    # Theming
    numix-icon-theme-circle
    colloid-icon-theme
    catppuccin-gtk
    catppuccin-kvantum
  ];

  home.sessionVariables = {
    GTK_THEME = "catppuccin-macchiato-teal-standard";
    XCURSOR_THEME = "Catppuccin-Macchiato-Teal";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Catppuccin-Macchiato-Teal";
    HYPRCURSOR_SIZE = "24";
  };

  # Enable Theme
  qt = {
    enable = true;
    platformTheme.name = "gtk2";
    style.name = "gtk2";
  };
}
