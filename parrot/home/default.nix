{ pkgs, inputs, ... }:
{
  imports = [
    ../../shared/shell
    ../../shared/ssh.nix
    ../../shared/git.nix
    ../../shared/desktop/dev
    ../../shared/desktop
  ];

  desktop.enable = true;

  dconf.enable = true;

  xdg.configFile."hypr/pyprland.json".source = ../../shared/desktop/hyprland/pyprland.json;

  home = {
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.05";

    packages =
      with pkgs;
      [
        # Desktop
        swww
        dunst
        libnotify
        brightnessctl
        grim
        slurp
        pyprland
        hyprland-protocols
        hyprcursor

        # Sound
        pwvucontrol
        pulseaudio

        # Networking
        networkmanagerapplet
        networkmanager

        # File managers
        xfce.thunar
        xfce.thunar-volman

        # Browser
        librewolf
        chromium

        # Other gui apps
        thunderbird
        mousam
        bitwarden-desktop
        eduvpn-client
        gimp
        vlc
        obs-studio
        mupdf
        feh

        # Social media
        vesktop

        # Bluetooth
        bluez
        blueman

        # Games
        godot_4
        gdtoolkit_4
        steam-run-free
        steam
        mgba
        prismlauncher
        master.osu-lazer-bin

        ## Drivers/Requirements
        meson
        wine
        winetricks
        wine-wayland
        zlib

        # Miscs
        upower
        texliveFull
        wkhtmltopdf
        libreoffice-qt-fresh
      ]
      ++ (import ./../../shared/desktop/bin { inherit pkgs; });

    # For env var
    sessionVariables = {
      EDITOR = "nvim";
      NIX_AUTO_RUN = 1;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
