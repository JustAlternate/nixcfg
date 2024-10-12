{ pkgs, ... }: {
  imports = [
    ./hyprland
    ./eww
    ../../../shared/rofi
    ../../../shared/fastfetch
    ../../../shared/pywal
    ../../../shared/kitty.nix
  ];

  home.packages = with pkgs; [
    birdtray
    patray
  ];

  services.trayer = {
    enable = true;
    settings.transparent = false;
    settings.tint = "0x282c34";
  };

  home.sessionVariables = {
    XCURSOR_THEME = "Numix-Cursor";
    XCURSOR_SIZE = "24";
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

    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
    };

    # gtk3.extraConfig = {
    #   Settings = ''
    #     gtk-application-prefer-dark-theme=1
    #   '';
    # };
    #
    # gtk4.extraConfig = {
    #   Settings = ''
    #     gtk-application-prefer-dark-theme=1
    #   '';
    # };
  };
}
