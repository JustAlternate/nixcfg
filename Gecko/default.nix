{ lib, pkgs, ... }:
{
  imports = [
    ../shared/optimise.nix
  ];

  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "fr";
    useXkbConfig = true; # use xkb.options in tty.
  };

  services.xserver.xkb.layout = "fr";

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    htop
    nmon
    cmatrix
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  users = {
    # set Zsh as the default user shell for all users
    defaultUserShell = pkgs.zsh;
    users.root.openssh.authorizedKeys.keys = [
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSO4cOiA8s9hVyPtdhUXdshxDXXPU15qM8xE0Ixfc21''
    ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "vi-mode"
      ];
      theme = "agnoster";
    };
    shellAliases = {
      temp = "vcgencmd measure_temp";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}
