{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    ./nginx # Web server, reverse proxy
    ./planka # selfhosted Kanban
    ./vaultwarden
    ./owncloud # selhosted google drive
    ./hauk # selfhosted google maps sharing location service
    ./mail
    ./minecraft
    ./action-runner
    ../shared/sops.nix # Secrets management using ssh key
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    optimise.automatic = true;

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  environment = {
    systemPackages = with pkgs; [
      busybox
      vim
      git
      home-manager
      docker-client
      lego
      unstable.morph
    ];
  };

  programs.zsh.enable = true;
  services.openssh.enable = true;
  users = {
    # set Zsh as the default user shell for all users
    defaultUserShell = pkgs.zsh;
    users.root.openssh.authorizedKeys.keys = [
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSO4cOiA8s9hVyPtdhUXdshxDXXPU15qM8xE0Ixfc21''
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "nixos-beaver-8gb-nbg1-3";
  networking.domain = "";

  # sslh for ssh through https in order to get around school wifi ssh port 22 firewall
  services.sslh = {
    enable = true;
    listenAddress = "0.0.0.0";
    verbose = false;
    settings = {
      protocols = [
        {
          host = "localhost";
          name = "http";
          port = "80";
        }
        # Redirect 443 https to 8443
        {
          host = "localhost";
          name = "tls";
          port = "8443";
        }
        {
          host = "localhost";
          name = "ssh";
          port = "22";
        }
      ];
    };
  };

  system.stateVersion = "23.11";
}
