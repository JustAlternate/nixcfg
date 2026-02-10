{ pkgs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    ../shared/sops.nix # Secrets management using ssh key
    ../shared/optimise.nix
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
    users.root.openssh.authorizedKeys.keyFiles = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSO4cOiA8s9hVyPtdhUXdshxDXXPU15qM8xE0Ixfc21 justalternate@archlinux";
      # config.sops.secrets."ROOT_SSH_AUTHORIZED_KEY".path
    ];
  };

  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "nixos-beaver-8gb-nbg1-3";
  networking.domain = "";

  system.stateVersion = "23.11";
}
