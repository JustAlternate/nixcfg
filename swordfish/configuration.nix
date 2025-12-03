{ pkgs, inputs, ... }:
{
  # CONFIGURATION FOR A HOMEMADE GAMING RIG FEATURING
  # Motherboard: B550 GAMING X
  # CPU: AMD Ryzen 7 5800X
  # GPU: AMD Radeon RX 6800
  # RAM: 32G
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../shared/desktop/dev/docker/default.nix
    ../shared/sops.nix
    ../shared/optimise.nix
    ../shared/security.nix

    inputs.hyprland.nixosModules.default
  ];

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

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

  xdg = {
    portal = {
      config.common.default = "*";
      enable = true;
      wlr.enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # fonts:
  fonts.packages = with pkgs; [ nerd-fonts.hack ];

  # Bootloader.
  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.kernelModules = [ "amdgpu" ];
  };

  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
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
    openssh.enable = true;

    xserver = {
      videoDrivers = [ "amdgpu" ];
      wacom.enable = true;

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

    ollama = {
      enable = true;
      acceleration = "rocm";
      package = pkgs.ollama;
      environmentVariables = {
        HSA_OVERRIDE_GFX_VERSION = "10.3.0";
      };
    };
  };

  # Configure console keymap
  console.keyMap = "fr";

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    # ckb-next.enable = true;
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
  };

  programs = {
    zsh.enable = true;

    hyprland = {
      enable = true;
      settings = {
        env = [ 
          "ELECTRON_OZONE_PLATFORM_HINT, auto"
        ];
        cursor = {
          enable_hyprcursor = true;
          no_hardware_cursors = true;
        };
      };
      extraConfig = ''
        # Monitor settings
        monitor=DP-3, 2560x1440@165, 1920x0, 1
        monitor=DP-1, 2560x1440@165, 1920x0, 1
        monitor=HDMI-A-1, 1920x1080@60, 0x0, 1

        ${builtins.readFile ../shared/desktop/hyprland/hyprland.conf}
      '';
    };
  };

  networking = {
    hostName = "nixos"; # Define your hostname.
    interfaces."enp4s0".wakeOnLan.enable = true;
    # Enable networking
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
        53 67 68
        51820   # WireGuard default
        1194    # OpenVPN default
        443     # Some eduVPN setups use 443/UDP or 443/TCP
      ];
      checkReversePath = "loose";
    };
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11";
}
