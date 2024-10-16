{ pkgs
, inputs
, ...
}:
{
  imports = [
    ./rice
    ./zsh.nix
    ./dev
    ./nvim
    ../../shared/ssh.nix
    ../../shared/git.nix
    ../../shared/display-manager.nix
  ];
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
    stateVersion = "24.05";

    packages = with pkgs;
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

        # Terminals
        kitty

        # File managers
        xfce.thunar
        xfce.thunar-volman
        unstable.yazi

        # Browser
        chromium
        firefox-wayland

        # Other gui apps
        thunderbird
        unstable.mousam

        # Music
        mpv
        youtube-music

        # Video
        ffmpeg
        vlc
        obs-studio
        inputs.lobster.packages.x86_64-linux.lobster

        # Image
        imagemagick
        mupdf
        feh
        gimp
        cinnamon.pix
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
        neovim-remote
        pandoc
        lazygit

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
        hmcl
        steam
        unstable.osu-lazer-bin
        bottles

        ## Drivers/Requirements
        ckb-next
        meson
        jdk17
        wine
        winetricks
        wine-wayland
        zlib

        # Miscs
        cpu-x
        marp-cli

      ]
      ++ (import ./bin { inherit pkgs; });

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
