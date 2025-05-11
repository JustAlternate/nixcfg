{ pkgs, ... }:
{
  imports = [
    ../../shared/zsh.nix
    ../../shared/ssh.nix
    ../../shared/git.nix
    ../../shared/desktop/dev
    ../../shared/desktop/rice.nix
  ];

  desktop.enable = true;

  wayland.windowManager.hyprland.extraConfig = ''
    # Monitor settings
    monitor=DP-3, 2560x1440@165, 1920x0, 1
    monitor=HDMI-A-1, 1920x1080@60, 0x0, 1
  '';

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
        eww
        dunst
        libnotify
        brightnessctl
        grimblast

        # Sound
        pwvucontrol
        pulseaudio

        # Networking
        networkmanagerapplet
        networkmanager

        # File managers
        xfce.thunar
        xfce.thunar-volman
        yazi
        gparted

        # Browser
        chromium
        firefox-wayland

        # Other gui apps
        thunderbird
        bitwarden-desktop

        # Music
        mpv
        youtube-music

        # Video
        ffmpeg
        vlc
        obs-studio

        ## Video editing
        #kdePackages.kdenlive

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
        godot3
        steam
        appimage-run
        pokemmo-installer
        osu-lazer-bin
        hmcl
        mgba

        ## Drivers/Requirements
        wacomtablet
        opentabletdriver
        ckb-next
        meson
        wine
        winetricks
        wine-wayland
        zlib
        lego
        android-udev-rules
        android-studio

        # Miscs
        cpu-x
        marp-cli
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
