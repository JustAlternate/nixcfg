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

  services.kdeconnect.enable = true;

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

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 20;
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Hack";
      size = 11;
    };
  };
}
