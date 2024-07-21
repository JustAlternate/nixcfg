{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
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
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # Desktop
    pkgs.swww
    pkgs.waybar
    pkgs.dunst
    pkgs.libnotify
    pkgs.brightnessctl
    pkgs.grimblast
    pkgs.pywal

    # Sound
    pkgs.pwvucontrol

    # Networking
    pkgs.networkmanagerapplet
    pkgs.networkmanager

    # Text editors
    pkgs.vim

    # Terminals
    pkgs.kitty

    # File managers
    pkgs.xfce.thunar
    pkgs.xfce.thunar-volman
    pkgs.dolphin

    # Browser
    pkgs.firefox
    pkgs.chromium

    # Music
    pkgs.mpv
    pkgs.youtube-music

    # Video
    pkgs.vlc

    # Image
    pkgs.mupdf
    pkgs.feh
    pkgs.gimp
    pkgs.cinnamon.pix

    # Social media
    pkgs.vesktop

    # Cli tools
    pkgs.unzip
    pkgs.zsh
    pkgs.wget
    pkgs.wl-clipboard
    pkgs.wl-clipboard-x11
    pkgs.cliphist
    pkgs.busybox
    pkgs.fastfetch
    pkgs.ani-cli
    pkgs.cmatrix
    pkgs.eza
    pkgs.nvtopPackages.full
    pkgs.cava
    pkgs.lshw
    pkgs.powertop
    pkgs.ripgrep
    pkgs.thefuck

    # Developpment
    pkgs.openssh
    pkgs.scdoc
    pkgs.git
    pkgs.gcc
    pkgs.cmake
    pkgs.python3
    pkgs.go

    # App launchers
    pkgs.rofi-wayland
    pkgs.wofi

    # Games
    pkgs.meson
    pkgs.hmcl
    pkgs.jdk17
    pkgs.steam
    pkgs.wine
    pkgs.winetricks
    pkgs.wine-wayland

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
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

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/justalternate/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.neovim = {
    enable = true;
    extraConfig = ''
      set number relativenumber
      set clipboard=unnamedplus
    '';
  };

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
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "thefuck" ];
      theme = "agnoster";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
