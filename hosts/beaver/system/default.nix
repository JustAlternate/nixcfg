{ pkgs, ... }:
{
  imports = [
    ../../../profiles/nixos/core/identity.nix
    ./hardware.nix
    ./networking.nix
    ../../../modules/nixos/sops.nix
    ./secrets.nix
    ../../../modules/nixos/tailscale.nix
    ../../../profiles/nixos/core/nix.nix
    ./services
  ];

  environment = {
    systemPackages = with pkgs; [
      coreutils-full
      git
      home-manager
      lego
      ghostty.terminfo
      openssl
      sqlite
      jq
      dig
      unzip
    ];
  };

  services = {
    nginx = {
      appendHttpConfig = ''
        proxy_headers_hash_max_size 512;
        proxy_headers_hash_bucket_size 128;
      '';
    };
    tailscale.advertiseExitNode = true;
    journald.extraConfig = ''
      SystemMaxUse=300M
      MaxRetentionSec=1month
    '';
    fail2ban = {
      enable = true;
      bantime = "1h";
      maxretry = 3;
      ignoreIP = [
        "127.0.0.1/8"
        "::1"
        "100.64.0.0/10" # tailscale CGNAT — never ban mesh-sourced SSH
      ];
      jails = {
        sshd = {
          settings = {
            enabled = true;
            port = "22,8443";
            maxretry = 3;
            bantime = "1h";
          };
        };
        postfix-sasl = {
          settings = {
            enabled = true;
            port = "smtp,465,submission";
            maxretry = 3;
            bantime = "1h";
          };
        };
        dovecot = {
          settings = {
            enabled = true;
            port = "imap,imaps,pop3,pop3s,submission";
            maxretry = 3;
            bantime = "1h";
          };
        };
        nginx-botsearch = {
          settings = {
            enabled = true;
            port = "http,https";
            maxretry = 5;
            bantime = "1h";
            findtime = "10m";
          };
        };
      };
    };
    openssh = {
      enable = true;
      ports = [
        22
        8443
      ];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
        MaxAuthTries = 3;
        LoginGraceTime = 30;
      };
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

  boot = {
    tmp.cleanOnBoot = true;
    kernelParams = [ "console=tty1" ];

    # 256M ESP (sdb15, wedged between sdb14/sdb1, cannot grow without rescue).
    # Each kernel pair is ~86M; GRUB keeps current + 1 previous generation
    # (2 entries = ~186M peak). 3 entries (limit=2) overflows the ESP during
    # the copy phase, which happens *before* old files are pruned -> switch
    # fails like it did on 2026-08-28. If /boot has <95M free before a
    # rebuild, delete the oldest pair in /boot/kernels manually first.
    loader.grub.configurationLimit = 1;
  };

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
