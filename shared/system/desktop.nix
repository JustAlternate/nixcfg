{ pkgs, ... }:
{
  imports = [
    ../desktop/hyprland
    ../desktop/dev/docker/default.nix
    ../sops.nix
    ../optimise.nix
    ../security.nix
  ];

  environment = {
    shells = with pkgs; [ zsh ];
    systemPackages = with pkgs; [
      busybox
      git
      vim
    ];

    sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
    };
  };

  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [ nerd-fonts.hack ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    networkmanager.plugins = with pkgs; [ networkmanager-openvpn ];
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
      ];
      allowedUDPPorts = [
        53
        67
        68
        51820 # WireGuard default
        1194 # OpenVPN default
        443 # Some eduVPN setups use 443/UDP or 443/TCP
      ];
      checkReversePath = "loose";
    };
  };

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  services = {
    xserver = {
      xkb.layout = "fr";
      xkb.variant = "";
    };

    dbus.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    ollama.enable = true;
  };

  console.keyMap = "fr";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  xdg.portal = {
    config.common.default = "*";
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  programs.zsh.enable = true;
}
