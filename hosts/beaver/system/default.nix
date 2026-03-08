{ pkgs, ... }:
{
  imports = [
    ../../../nixos/core/machine-name.nix
    ./hardware.nix
    ./networking.nix # generated at runtime by nixos-infect
    ../../../modules/sops.nix # Secrets management using ssh key
    ../../../nixos/core/nix.nix
    ./services
  ];

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
  };

  environment = {
    systemPackages = with pkgs; [
      coreutils-full
      git
      home-manager
      podman
      podman-compose
      lego
      ghostty.terminfo
    ];
  };

  services = {
    journald.extraConfig = ''
      SystemMaxUse=800M
      MaxRetentionSec=1month
    '';
    fail2ban.enable = true;
    openssh.enable = true;
    openssh.settings = {
      Port = 8443;
      PasswordAuthentication = false;
    };
  };
  users = {
    # set Zsh as the default user shell for all users
    defaultUserShell = pkgs.zsh;
    users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSO4cOiA8s9hVyPtdhUXdshxDXXPU15qM8xE0Ixfc21 justalternate@archlinux"
    ];
  };

  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Cachix cache configuration
  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
      "https://justalternate-nixcfg.cachix.org"
    ];
    trusted-public-keys = [
      "justalternate-nixcfg.cachix.org-1:Bzqq/ByZOKxWH3ByZ0EWs2e+U7sP15yC0/15auvsR2k="
    ];
  };

  boot.tmp.cleanOnBoot = true;

  # Mount 40GB Hetzner volume at /var
  fileSystems."/var" = {
    device = "/dev/sdb";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
    ];
  };

  # Ensure standard /var directories exist on fresh mount
  systemd.tmpfiles.rules = [
    "d /var/lib 0755 root root -"
    "d /var/log 0755 root root -"
    "d /var/cache 0755 root root -"
    "d /var/tmp 1777 root root -"
    "d /var/run 0755 root root -"
    "d /var/spool 0755 root root -"
    "d /var/mail 0755 root root -"
  ];

  zramSwap.enable = true;
  swapDevices = [
    {
      device = "/swapfile";
      size = 4096;
    }
  ];
  networking.hostName = "nixos-beaver-8gb-nbg1-3";
  networking.domain = "";

  machineName = "beaver";

  system.stateVersion = "23.11";
}
