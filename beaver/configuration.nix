{ pkgs, ... }:
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
      busybox
      git
      home-manager
      podman
      podman-compose
      lego
    ];
  };

  services = {
    fail2ban.enable = true;

    # # sslh for ssh through https in order to get around school wifi ssh port 22 firewall
    # sslh = {
    #   enable = true;
    #   listenAddresses = "0.0.0.0";
    #   settings = {
    #     protocols = [
    #       {
    #         host = "localhost";
    #         name = "http";
    #         port = "80";
    #       }
    #       # Redirect 443 https to 8443
    #       {
    #         host = "localhost";
    #         name = "tls";
    #         port = "8443";
    #       }
    #       {
    #         host = "localhost";
    #         name = "ssh";
    #         port = "22";
    #       }
    #     ];
    #   };
    # };
    openssh.enable = true;
    openssh.settings = {
      PasswordAuthentication = false;
    };
  };
  users = {
    # set Zsh as the default user shell for all users
    defaultUserShell = pkgs.zsh;
    users.root.openssh.authorizedKeys.keys = [
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSO4cOiA8s9hVyPtdhUXdshxDXXPU15qM8xE0Ixfc21''
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
