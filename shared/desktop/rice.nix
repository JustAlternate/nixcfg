{ pkgs, ... }:
{
  imports = [
    ./rofi
    ./pywal
    ./hyprland
    ./kitty.nix
    ../fastfetch.nix
  ];

  # Override packages
  nixpkgs.config.packageOverrides = pkgs: {
    colloid-icon-theme = pkgs.colloid-icon-theme.override { colorVariants = [ "teal" ]; };
    catppuccin-gtk = pkgs.catppuccin-gtk.override {
      accents = [ "teal" ]; # You can specify multiple accents here to output multiple themes
      size = "standard";
      variant = "macchiato";
    };
  };

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
    catppuccin-cursors.macchiatoTeal
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
