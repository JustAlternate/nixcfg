{ pkgs, ... }:
{
  imports = [
    ../../shared/shell
    ../../shared/ssh.nix
    ../../shared/git.nix
    ../../shared/desktop/dev
    ../../shared/desktop
  ];

  desktop.enable = true;

  xdg.configFile."hypr/pyprland.json".source = ../../shared/desktop/hyprland/pyprland.json;

  home = {
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.11";

    packages =
      with pkgs;
      [
        # Desktop
        swww
        dunst
        libnotify
        brightnessctl
        grimblast
        pyprland
        hyprland-protocols
        hyprcursor
        grim
        slurp

        # Sound
        pwvucontrol
        pulseaudio

        # Networking
        networkmanagerapplet
        networkmanager

        # File managers
        xfce.thunar
        xfce.thunar-volman
        gparted

        # Browser
        firefox
        librewolf
        libreoffice-qt-fresh

        # Other gui apps
        thunderbird
        bitwarden-desktop
        eduvpn-client

        # Music
        mpv
        youtube-music

        # Video
        ffmpeg
        vlc
        obs-studio

        # Image
        imagemagick
        mupdf
        feh
        gimp
        satty

        # Social media
        vesktop
        bemoji

        # Bluetooth
        bluez
        blueman

        # Games
        ultrastardx
        lutris
        godot3
        steam
        appimage-run
        pokemmo-installer
        master.osu-lazer-bin
        prismlauncher
        mgba

        ## Drivers/Requirements
        opentabletdriver
        meson
        wine
        winetricks
        wine-wayland
        zlib
        lego

        texliveFull
      ]
      ## Install my custom scripts
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
