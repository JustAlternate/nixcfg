{ pkgs, ... }:
{
  imports = [
    ./rofi
    ./waybar
    ./pywal
    ./hyprland
    ./kitty.nix
    ../fastfetch.nix
    ./dunst.nix
  ];

  home.packages = with pkgs; [
    birdtray
    patray
    unrar
    bc
    spacedrive
    fractal

    # Theming
    numix-icon-theme-circle
    colloid-icon-theme
    catppuccin-gtk
    catppuccin-kvantum

    yubioath-flutter
    yubikey-manager
    yubikey-agent
    yubikey-personalization-gui
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

  programs.swaylock = {
    enable = true;
    settings = {
      # screenshots = true;
      clock = true;
      indicator = true;
      show-failed-attempts = true;
      # ignore-empty-password = true;
      grace = 2;
      effect-blur = "7x5";
      effect-vignette = "0.6:0.6";
      # ring-color = colors.hex colors.accent;
      # ring-ver-color = colors.hex colors.green;
      # ring-wrong-color = colors.hex colors.red;
      # key-hl-color = colors.hex colors.primary;
      color = "00000000";
      line-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";
      inside-color = "00000000";
      inside-ver-color = "00000000";
      inside-wrong-color = "00000000";
      separator-color = "00000000";
      # text-color = colors.hex colors.light;
    };
  };

}
