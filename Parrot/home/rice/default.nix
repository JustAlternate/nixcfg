{ pkgs, ... }: {
  imports = [
    ./pywal
    ./hyprland
    ./eww
    ./rofi
    ./fastfetch
    ../../../shared/kitty.nix
  ];

  home.packages = with pkgs; [
    trayer
    palenight-theme
  ];

  nixpkgs.config.packageOverrides = pkgs: {
    colloid-icon-theme = pkgs.colloid-icon-theme.override { colorVariants = [ "teal" ]; };
    catppuccin-gtk = pkgs.catppuccin-gtk.override {
      accents = [ "teal" ];
      size = "standard";
      variant = "macchiato";
    };
  };

  home.sessionVariables = {
    GTK_THEME = "palenight";
    # GTK_THEME = "catppuccin-macchiato-teal-standard";
    # XCURSOR_THEME = "Catppuccin-Macchiato-Teal";
    XCURSOR_THEME = "Numix-Cursor";
    XCURSOR_SIZE = "24";
    # HYPRCURSOR_THEME = "Catppuccin-Macchiato-Teal";
    HYPRCURSOR_THEME = "Numix-Cursor";
    HYPRCURSOR_SIZE = "24";
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk2";
    style.name = "gtk2";
  };

  gtk = {
    enable = true;

    iconTheme = {
      name = "Reversal";
      package = pkgs.reversal-icon-theme;
    };

    theme = {
      name = "palenight";
      package = pkgs.palenight-theme;
    };

    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
    };

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };
}
