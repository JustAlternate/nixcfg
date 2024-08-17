{ pkgs, ... }: {
  imports = [
    ./pywal
    ./hyprland
    ./eww
    ./rofi
    ./fastfetch
  ];

  home.sessionVariables = {
    GTK_THEME = "Material-dark";
    XCURSOR_THEME = "pokemon-cursor";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "pokemon-cursor";
    HYPRCURSOR_SIZE = "24";
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };


  gtk = {
    enable = true;
    theme = {
      name = "Materia-dark";
      package = pkgs.materia-theme;
    };
    cursorTheme.package = pkgs.pokemon-cursor;
    cursorTheme.name = "pokemon-cursor";

    iconTheme.package = pkgs.papirus-icon-theme;
    iconTheme.name = "Papirus";
  };
}
