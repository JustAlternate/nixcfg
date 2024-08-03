{ config, pkgs, inputs, ... }:
let
  master = import inputs.master { system = "x86_64-linux"; config.allowUnfree = true; };
in
{
  imports = [
    ./rice/pywalfox.nix
    ./rice/hyprland.nix
    ./rice/nvim/lazynvim.nix
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
    # desktop
    swww
    eww
    dunst
    libnotify
    brightnessctl
    grimblast
    pywal
    conky
    pyprland
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
    dolphin

    # Browser
    chromium
    firefox-wayland

    # Music
    mpv
    youtube-music

    # Video
    vlc
    obs-studio

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
    zsh
    wget
    wl-clipboard
    wl-clipboard-x11
    cliphist
    busybox
    eza
    ripgrep
    thefuck
    pamixer
    zoxide
    fzf
    socat
    jq
    ani-cli
    sshfs

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
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # For env var
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Programs configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  
    shellAliases = {
      ll = "ls -l";
      nixcfg = "nvim ~/.config/dotfiles";
      rebuildsys = "sudo nixos-rebuild switch --flake ~/.config/dotfiles";
      rebuildhome = "home-manager switch --flake ~/.config/dotfiles";
      ls = "eza --color=auto --icons=always";
      suspend = "systemctl suspend";
      cd = "z";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "dotenv" "vi-mode" ];
      theme = "agnoster";
    };
    initExtra = ''
      fastfetch -c examples/8 
      eval "$(zoxide init zsh)"
    '';
    initExtraFirst = ''
      cat /home/justalternate/.cache/wal/sequences
    '';

  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
