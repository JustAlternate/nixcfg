{ config, pkgs, ... }:
{
  # CONFIGURATION FOR A ASUS TUF Gaming A15 FA506ICB_FA506ICB
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../shared/sops.nix
    ../shared/desktop/dev/docker/default.nix
    ../shared/optimise.nix
  ];

  environment = {
    shells = with pkgs; [ zsh ];

    systemPackages = with pkgs; [
      iw
      pipewire
      wireplumber
      git
      vim
      home-manager
      gparted
      parted
    ];

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      GBM_BACKEND = "nvidia_drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS = "1";
      LIBVA_DRIVER_NAME = "nvidia";
      XDG_SESSION_TYPE = "wayland";
      __NV_PRIME_RENDER_OFFLOAD = "1";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # fonts:
  fonts.packages = with pkgs; [ nerdfonts ];

  # Bootloader.
  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };
  };

  users.defaultUserShell = pkgs.zsh;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking = {
    networkmanager.enable = true;
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
      ];
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

  services = {
    xserver = {
      # Configure keymap in X11

      xkb.layout = "fr";
      xkb.variant = "";

      # Load nvidia driver for Xorg and Wayland
      videoDrivers = [
        # "nvidia"
        "amdvlk"
      ];
    };

    # sound using pipewire:
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # ollama = {
    #   enable = true;
    #   acceleration = "cuda";
    #   package = pkgs.master.ollama;
    # };
    # open-webui.enable = true;

    # Enable automatic login for the user.
    getty.autologinUser = "justalternate";

    dbus.enable = true;
    gnome.gnome-keyring.enable = true;
    upower.enable = true;
    tlp = {
      enable = true;
      settings = {
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        CPU_BOOST_ON_BAT = 0;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;
        AMDGPU_ABM_LEVEL_ON_BAT = 3;
        #Optional helps save long term battery health
        START_CHARGE_THRESH_BAT0 = 70; # and bellow it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 90; # and above it stops charging
      };
    };
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.justalternate = {
    home = "/home/justalternate";
    isNormalUser = true;
    description = "justalternate";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

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
    graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        amdvlk
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    #   nvidia = {
    #     # Modesetting is required.
    #     modesetting.enable = true;
    #
    #     # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    #     # Enable this if you have graphical corruption issues or application crashes after waking
    #     # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    #     # of just the bare essentials.
    #     powerManagement.enable = false;
    #
    #     # Fine-grained power management. Turns off GPU when not in use.
    #     # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    #     powerManagement.finegrained = true;
    #
    #     # Use the NVidia open source kernel module (not to be confused with the
    #     # independent third-party "nouveau" open source driver).
    #     # Support is limited to the Turing and later architectures. Full list of
    #     # supported GPUs is at:
    #     # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    #     # Only available from driver 515.43.04+
    #     # Currently alpha-quality/buggy, so false is currently the recommended setting.
    #     open = false;
    #
    #     # Enable the Nvidia settings menu,
    #     # accessible via `nvidia-settings`.
    #     nvidiaSettings = true;
    #
    #     # Optionally, you may need to select the appropriate driver version for your specific GPU.
    #     package = config.boot.kernelPackages.nvidiaPackages.stable;
    #
    #     prime = {
    #       offload.enable = true;
    #       # Make sure to use the correct Bus ID values for your system!
    #       nvidiaBusId = "PCI:5:0:0";
    #       amdgpuBusId = "PCI:1:0:0";
    #     };
    #   };
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

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  programs = {
    zsh.enable = true;

    # Enable ssh-agent
    ssh.startAgent = true;

    hyprland.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05";
}
