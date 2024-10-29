{ pkgs, ... }: {

  imports = [
    ./hyprland
    ./eww
    ../../../shared/kitty.nix
    ../../../shared/pywal
    ../../../shared/rofi
    ../../../shared/fastfetch
  ];

  home.packages = with pkgs; [
    trayer
  ];

  home.sessionVariables = {
    # GTK_THEME = "Materia-dark";
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

    # theme = {
    #   name = "Materia-dark";
    #   package = pkgs.materia-theme;
    # };

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
