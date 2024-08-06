{ config, pkgs, inputs, ... }:
let
  master = import inputs.master { system = "x86_64-linux"; config.allowUnfree = true; };
in
{
  imports = [
    ./rice
    ./nvim
    ./zsh.nix
    ./ssh
  ];
  home.username = "justalternate";
  home.homeDirectory = "/home/justalternate";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
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

    # Browser
    chromium
    firefox-wayland

    # Music
    mpv
    youtube-music

    # Video
    vlc
    obs-studio
    inputs.lobster.packages.x86_64-linux.lobster

    # Image
    mupdf
    feh
    gimp
    cinnamon.pix

    # Social media
    vesktop

    # Cli tools

    ## Utility
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

    ## Show-off
    fastfetch
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

    # Developpment
    openssh
    scdoc
    git
    gcc
    cmake

    # Launchers
    rofi-wayland

    # Games
    hmcl
    steam
    master.osu-lazer-bin

    ## Drivers/Requirements
    meson
    jdk17
    wine
    winetricks
    wine-wayland
  ] ++ (import ./bin { inherit pkgs ; });

  # For env var
  home.sessionVariables = {
    EDITOR = "nvim";
    NIX_AUTO_RUN = 1;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
