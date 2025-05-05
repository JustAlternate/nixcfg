{ pkgs, ... }:
{
  imports = [
    ./rice/eww
    ../../shared/zsh.nix
    ../../shared/ssh.nix
    ../../shared/git.nix
    ../../shared/desktop/dev
    ../../shared/desktop/rice.nix
  ];

  desktop.enable = true;

  wayland.windowManager.hyprland.extraConfig = ''
    env = WLR_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1
    # Monitor settings
    monitor=eDP-1, 1920x1080, 0x1080, 1
    monitor=HDMI-A-1, 1920x1080, 0x0, 1
  '';

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
        networkmanager-openconnect
        networkmanager
        wireguard-tools
        wg-netmanager

        # File managers
        xfce.thunar
        xfce.thunar-volman
        yazi

        # Browser
        chromium
        firefox-wayland

        # Other gui apps
        thunderbird
        mousam
        bitwarden-desktop

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
        godot_4
        gdtoolkit_4
        steam-run-free
        steam
        bottles
        mgba

        ## Drivers/Requirements
        ckb-next
        meson
        wine
        winetricks
        wine-wayland
        zlib

        # Miscs
        cpu-x
        marp-cli
        upower
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
