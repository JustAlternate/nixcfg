{ pkgs, ... }: {
  imports = [
    ./pywal
    ./hyprland
    ./eww
    ./rofi
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

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos_small";
        padding = {
          right = 1;
        };
      };

      display = {
        binaryPrefix = "si";
        color = "blue";
        separator = "  ";
      };

      modules = [
        "host"
        "os"
        "uptime"
        "cpu"
        "memory"
        "colors"
      ];
    };
  };
}
