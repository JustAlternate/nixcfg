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

  wayland.windowManager.hyprland.extraConfig = ''
    # Monitor settings
    monitor=DP-3, 2560x1440@165, 1920x0, 1
    monitor=HDMI-A-1, 1920x1080@60, 0x0, 1
  '';

  home = {
    username = "justalternate";
    homeDirectory = "/home/justalternate";

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
        conky

        # Sound
        pwvucontrol
        pulseaudio

        # Networking
        networkmanagerapplet
        networkmanager

        # Text editors
        vim
        master.windsurf

        # Terminals
        kitty

        # File managers
        xfce.thunar
        xfce.thunar-volman
        unstable.yazi
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

        # Cli tools
        ## Utility
        xdg-utils
        playerctl
        unzip
        wget
        wl-clipboard
        wl-clipboard-x11
        cliphist
        busybox
        ripgrep
        thefuck
        pamixer
        fzf
        socat
        jq
        ani-cli
        sshfs
        pandoc
        lazygit
        statix # Lints and suggestions for the nix programming language
        deadnix # Find and remove unused code in .nix source files
        nixfmt-rfc-style # Nix Code Formatter

        ## Show-off
        cmatrix
        cava
        cbonsai

        ## Monitoring
        nvtopPackages.full
        htop
        powertop
        lshw
        acpi
        mission-center

        # Bluetooth
        bluez
        blueman

        # Games
        godot3
        steam
        appimage-run
        unstable.pokemmo-installer
        unstable.osu-lazer-bin

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

  nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
