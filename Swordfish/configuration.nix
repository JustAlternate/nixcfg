{ pkgs, ... }:
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

  xdg.portal = {
    config.common.default = "*";
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
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
    xserver = {
      videoDrivers = [ "amdgpu" ];
      wacom.enable = true;

      xkb.layout = "fr";
      xkb.variant = "";
    };

    dbus.enable = true;
    gnome.gnome-keyring.enable = true;

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
    # open-webui.enable = true;

    # Enable automatic login for the user.
    getty.autologinUser = "justalternate";
  };

  # Configure console keymap
  console.keyMap = "fr";

  security = {
    rtkit.enable = true;

    # For god sake pls stop asking for my passwd every 5 commands..
    sudo = {
      enable = true;
      extraConfig = ''
        justalternate ALL=(ALL) NOPASSWD: ALL
      '';
    };

    # Polkit.
    polkit.enable = true;
  };
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11";

  programs = {
    zsh.enable = true;
    ssh.startAgent = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };

  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.daemon.enable = true;

  services.openssh.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;
    users.justalternate = {
      home = "/home/justalternate/";
      isNormalUser = true;
      description = "justalternate";
      extraGroups = [
        "networkmanager"
        "wheel"
        "input"
        "uinput"
      ];
      initialPassword = "";
    };
    users.justalternate.openssh.authorizedKeys.keys = [
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSO4cOiA8s9hVyPtdhUXdshxDXXPU15qM8xE0Ixfc21''
    ];
  };

  networking = {
    hostName = "nixos"; # Define your hostname.
    interfaces."enp4s0".wakeOnLan.enable = true;
    # Enable networking
    networkmanager.enable = true;
  };
}
