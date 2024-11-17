{
  config,
  pkgs,
  lib,
  ...
}:
{
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

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # !!! Set to specific linux kernel version
  boot.kernelPackages = pkgs.linuxPackages;

  # Disable ZFS on kernel 6
  boot.supportedFilesystems = lib.mkForce [
    "vfat"
    "xfs"
    "cifs"
    "ntfs"
  ];

  # !!! Needed for the virtual console to work on the RPi 3, as the default of 16M doesn't seem to be enough.
  # If X.org behaves weirdly (I only saw the cursor) then try increasing this to 256M.
  # On a Raspberry Pi 4 with 4 GB, you should either disable this parameter or increase to at least 64M if you want the USB ports to work.
  boot.kernelParams = [ "cma=256M" ];

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  # !!! Adding a swap file is optional, but strongly recommended!
  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];

  # systemPackages
  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    bind
    iptables
    busybox
    git
  ];

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
    };
  };

  virtualisation.docker.enable = true;

  networking.firewall.enable = false;

  # WiFi
  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };
  # Networking
  networking = {
    # useDHCP = true;
    interfaces.wlan0 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          # I used static IP over WLAN because I want to use it as local DNS resolver
          address = "192.168.1.4";
          prefixLength = 24;
        }
      ];
    };
    interfaces.eth0 = {
      useDHCP = true;
      # I used DHCP because sometimes I disconnect the LAN cable
      #ipv4.addresses = [{
      #  address = "192.168.100.3";
      #  prefixLength = 24;
      #}];
    };

    # Enabling WIFI
    wireless.enable = true;
    wireless.interfaces = [ "wlan0" ];
    # If you want to connect also via WIFI to your router
    # wireless.networks."SATRIA".psk = "wifipassword";
    # You can set default nameservers
    # nameservers = [ "192.168.100.3" "192.168.100.4" "192.168.100.1" ];
    # You can set default gateway
    # defaultGateway = {
    #  address = "192.168.1.1";
    #  interface = "eth0";
    # };
  };

  # forwarding
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv4.tcp_ecn" = true;
  };

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  users = {
    # set Zsh as the default user shell for all users
    defaultUserShell = pkgs.zsh;
    users.root.openssh.authorizedKeys.keys = [
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSO4cOiA8s9hVyPtdhUXdshxDXXPU15qM8xE0Ixfc21''
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "23.05";
}
