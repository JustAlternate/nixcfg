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
    ../shared/sops.nix
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Nix Gaming cache
      substituters = [ "https://nix-gaming.cachix.org" ];
      trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  environment = {
    shells = with pkgs; [ zsh ];

    systemPackages = with pkgs; [
      busybox
      pipewire
      wireplumber
      git
      vim
      home-manager
    ];

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
      XDG_SESSION_TYPE = "wayland";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # fonts:
  fonts.fonts = with pkgs; [ nerdfonts ];

  # Bootloader.
  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    loader = {
      grub = {
        enable = true;
        device = "/dev/nvme0n1";
        useOSProber = true;
        # Windows dual boot
        # extraEntries = ''
        #   menuentry "Windows" {
        #     insmod part_gpt
        #     insmod fat
        #     insmod search_fs_uuid
        #     insmod chain
        #     search --fs-uuid --set=root 78FC-1AE0
        #     chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        #   }
        # '';
      };
    };
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

  sound.enable = true;

  services = {
    xserver = {
      # Configure keymap in X11

      layout = "fr";
      xkbVariant = "";

      # Load nvidia driver for Xorg and Wayland
      videoDrivers = [ "amdvlk" ];
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    ollama = {
      enable = true;
      acceleration = "rocm";
      package = pkgs.unstable.ollama-rocm;
      environmentVariables = {
        HSA_OVERRIDE_GFX_VERSION = "10.3.0";
      };
    };
    open-webui.enable = true;

    # Enable automatic login for the user.
    getty.autologinUser = "justalternate";

    dbus.enable = true;
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
    polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          subject.isInGroup("users")
            && (
              action.id == "org.freedesktop.login1.reboot" ||
              action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
              action.id == "org.freedesktop.login1.power-off" ||
              action.id == "org.freedesktop.login1.power-off-multiple-sessions"
            )
          )
        {
          return polkit.Result.YES;
        }
      });
    '';
  };
  hardware = {
    # bluetooth:
    bluetooth.enable = true;

    # Enable OpenGL
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;

      extraPackages = with pkgs; [
        amdvlk
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05";

  xdg.portal = {
    config.common.default = "*";
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  programs = {
    zsh.enable = true;
    # Enable ssh-agent
    ssh.startAgent = true;
    hyprland.enable = true;
  };

  #services.xserver.wacom.enable = true;
  #hardware.opentabletdriver.enable = true;
  #hardware.opentabletdriver.daemon.enable = true;

  services.openssh.enable = true;
  users = {
    defaultUserShell = pkgs.zsh;
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.justalternate = {
      home = "/home/justalternate/";
      isNormalUser = true;
      description = "justalternate";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
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
